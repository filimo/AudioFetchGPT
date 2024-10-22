(function() {
    console.log('Start handling /backend-api/synthesize');

    const originalFetch = window.fetch;
    const queue = [];
    let processing = false;

    // Function to process the queue
    async function processQueue() {
        if (queue.length === 0 || processing) {
            return;
        }

        processing = true;
        const { input, init, resolve, reject } = queue.shift();

        try {
            const response = await originalFetch(input, init);
            await handleResponse(response, input, init, resolve, reject);
        } catch (error) {
            await handleFetchError(error, input, init, resolve, reject);
        }
    }

    // Function to handle the response
    async function handleResponse(response, input, init, resolve, reject) {
        if (!response.ok) {
            const error = new Error(`HTTP Error: ${response.status} ${response.statusText}`);
            error.response = response;
            await handleFetchError(error, input, init, resolve, reject);
            return;
        }

        try {
            const blob = await response.clone().blob();
            await processBlob(blob, input, response, resolve, reject);
        } catch (error) {
            await handleBlobError(error, reject);
        }
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
            name,
            queueLength: queue.length
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

        const url = new URL(input, window.location.origin);
        const messageId = url.searchParams.get('message_id') || '';

        const messageElement = document.querySelector(`[data-message-id="${messageId}"]`);
        const messageSnippet = messageElement ? messageElement.innerText.substring(0, 150) : 'Unknown message';

        showRetrySkipDialog(messageSnippet)
            .then(userChoice => {
                if (userChoice === 'retry') {
                    queue.unshift({ input, init, resolve, reject });
                } else if (userChoice === 'skip') {
                    resolve(null); // Resolve with null to signify skipping
                }
                processing = false;
                processQueue();
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
            Object.assign(dialogOverlay.style, {
                position: 'fixed',
                top: '0',
                left: '0',
                width: '100%',
                height: '100%',
                backgroundColor: 'rgba(0, 0, 0, 0.5)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                zIndex: '1000'
            });

            // Create dialog box
            const dialogBox = document.createElement('div');
            Object.assign(dialogBox.style, {
                backgroundColor: '#fff',
                padding: '20px',
                borderRadius: '5px',
                boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
                textAlign: 'center',
                maxWidth: '400px',
                width: '80%'
            });

            // Message with snippet
            const message = document.createElement('p');
            message.style.color = 'black';
            message.textContent = `An error occurred while loading voice for message: "${messageSnippet}". Would you like to retry?`;
            dialogBox.appendChild(message);

            // Buttons container
            const buttonsContainer = document.createElement('div');
            Object.assign(buttonsContainer.style, {
                marginTop: '20px',
                display: 'flex',
                justifyContent: 'space-around'
            });

            // Retry button
            const retryButton = document.createElement('button');
            Object.assign(retryButton.style, {
                padding: '10px 20px',
                backgroundColor: '#4CAF50',
                color: '#fff',
                border: 'none',
                borderRadius: '3px',
                cursor: 'pointer'
            });
            retryButton.textContent = 'Retry';

            // Skip button
            const skipButton = document.createElement('button');
            Object.assign(skipButton.style, {
                padding: '10px 20px',
                backgroundColor: '#f44336',
                color: '#fff',
                border: 'none',
                borderRadius: '3px',
                cursor: 'pointer'
            });
            skipButton.textContent = 'Skip';

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
            return new Promise((resolve, reject) => {
                queue.push({ input, init, resolve, reject });
                processQueue();
            });
        }
        return originalFetch(input, init);
    };
})();
