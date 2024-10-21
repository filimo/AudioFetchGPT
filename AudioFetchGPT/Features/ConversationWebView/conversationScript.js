(function() {
    console.log('Start handling /backend-api/synthesize');

    const originalFetch = window.fetch;
    const queue = [];
    let processing = false;

    // Function to process the queue
    function processQueue() {
        if (queue.length === 0 || processing) {
            return;
        }

        processing = true;
        const { input, init, resolve, reject } = queue.shift();

        originalFetch(input, init)
            .then(response => handleResponse(response, input, init, resolve, reject))
            .catch(error => handleFetchError(error, input, init, resolve, reject));
    }

    // Function to handle the response
    function handleResponse(response, input, init, resolve, reject) {
        if (!response.ok) {
            // Create an error based on the response status
            const error = new Error(`HTTP Error: ${response.status} ${response.statusText}`);
            error.response = response;
            handleFetchError(error, input, init, resolve, reject);
            return;
        }

        response.clone().blob()
            .then(blob => processBlob(blob, input, response, resolve, reject))
            .catch(error => handleBlobError(error, reject));
    }

    // Function to process the blob
    function processBlob(blob, input, response, resolve, reject) {
        const url = new URL(input, window.location.origin);
        const conversationId = url.searchParams.get('conversation_id') || '';
        const messageId = url.searchParams.get('message_id') || '';
        const nameElement = document.querySelector(`[data-message-id="${messageId}"]`);
        const name = nameElement ? nameElement.innerText : 'Unknown';

        const reader = new FileReader();
        reader.onloadend = () => sendMessageToWebKit(reader.result, conversationId, messageId, name, resolve, response);
        reader.readAsDataURL(blob);
    }

    // Function to send the message to WebKit
    function sendMessageToWebKit(audioData, conversationId, messageId, name, resolve, response) {
        window.webkit.messageHandlers.audioHandler.postMessage({
            conversationId,
            messageId,
            audioData,
            name
        });

        resolve(response);
        processing = false;
        processQueue();
    }

    // Function to handle blob errors
    function handleBlobError(error, reject) {
        console.error('Error reading blob:', error);
        reject(error);
        processing = false;
        processQueue();
    }

    // Function to handle fetch errors with retry/skip options
    function handleFetchError(error, input, init, resolve, reject) {
        console.error('Fetch error:', error);

        // Extract messageId from the input URL
        const url = new URL(input, window.location.origin);
        const messageId = url.searchParams.get('message_id') || '';

        // Get the message element and extract the first 50 characters
        const messageElement = document.querySelector(`[data-message-id="${messageId}"]`);
        const messageSnippet = messageElement ? messageElement.innerText.substring(0, 150) : 'Unknown message';

        // Create a custom dialog with "Retry" and "Skip" buttons, including the message snippet
        showRetrySkipDialog(messageSnippet)
            .then(userChoice => {
                if (userChoice === 'retry') {
                    // Add the request back to the queue for retrying
                    queue.unshift({
                        input,
                        init,
                        resolve,
                        reject
                    });
                    processing = false;
                    processQueue();
                } else if (userChoice === 'skip') {
                    // Skip the current request
                    processing = false;
                    processQueue();
                    resolve(null);  // Resolve with null to signify skipping
                }
            })
            .catch(dialogError => {
                console.error('Error displaying dialog:', dialogError);
                reject(dialogError);
                processing = false;
                processQueue();
            });
    }

    // Function to display a custom retry/skip dialog with message snippet
    function showRetrySkipDialog(messageSnippet) {
        return new Promise((resolve) => {
            // Create dialog overlay
            const dialogOverlay = document.createElement('div');
            dialogOverlay.style.position = 'fixed';
            dialogOverlay.style.top = '0';
            dialogOverlay.style.left = '0';
            dialogOverlay.style.width = '100%';
            dialogOverlay.style.height = '100%';
            dialogOverlay.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
            dialogOverlay.style.display = 'flex';
            dialogOverlay.style.alignItems = 'center';
            dialogOverlay.style.justifyContent = 'center';
            dialogOverlay.style.zIndex = '1000';

            // Create dialog box
            const dialogBox = document.createElement('div');
            dialogBox.style.backgroundColor = '#fff';
            dialogBox.style.padding = '20px';
            dialogBox.style.borderRadius = '5px';
            dialogBox.style.boxShadow = '0 2px 10px rgba(0,0,0,0.1)';
            dialogBox.style.textAlign = 'center';
            dialogBox.style.maxWidth = '400px';
            dialogBox.style.width = '80%';

            // Message with snippet
            const message = document.createElement('p');
            message.style.color = 'black';
            message.textContent = `An error occurred while loading voice for message: "${messageSnippet}". Would you like to retry?`;
            dialogBox.appendChild(message);

            // Buttons container
            const buttonsContainer = document.createElement('div');
            buttonsContainer.style.marginTop = '20px';
            buttonsContainer.style.display = 'flex';
            buttonsContainer.style.justifyContent = 'space-around';

            // Retry button
            const retryButton = document.createElement('button');
            retryButton.textContent = 'Retry';
            retryButton.style.padding = '10px 20px';
            retryButton.style.backgroundColor = '#4CAF50';
            retryButton.style.color = '#fff';
            retryButton.style.border = 'none';
            retryButton.style.borderRadius = '3px';
            retryButton.style.cursor = 'pointer';

            // Skip button
            const skipButton = document.createElement('button');
            skipButton.textContent = 'Skip';
            skipButton.style.padding = '10px 20px';
            skipButton.style.backgroundColor = '#f44336';
            skipButton.style.color = '#fff';
            skipButton.style.border = 'none';
            skipButton.style.borderRadius = '3px';
            skipButton.style.cursor = 'pointer';

            // Append buttons to container
            buttonsContainer.appendChild(retryButton);
            buttonsContainer.appendChild(skipButton);
            dialogBox.appendChild(buttonsContainer);
            dialogOverlay.appendChild(dialogBox);
            document.body.appendChild(dialogOverlay);

            // Event listeners for buttons
            retryButton.addEventListener('click', () => {
                document.body.removeChild(dialogOverlay);
                resolve('retry');
            });

            skipButton.addEventListener('click', () => {
                document.body.removeChild(dialogOverlay);
                resolve('skip');
            });
        });
    }

    // Override the fetch function
    window.fetch = function(input, init) {
        if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
            const url = new URL(input, window.location.origin);
            const conversationId = url.searchParams.get('conversation_id') || '';
            const messageId = url.searchParams.get('message_id') || '';

            if (window.__downloadedMessageIDs && window.__downloadedMessageIDs.includes(messageId)) {
                console.log(`Message ID ${messageId} already processed, fetch aborted.`);
                return Promise.resolve(new Response(null, { status: 409, statusText: 'Conflict: already processed' }));
            }

            return new Promise((resolve, reject) => {
                queue.push({ input, init, resolve, reject });
                processQueue();
            });
        }
        return originalFetch(input, init);
    };
})();
