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
            .then(response => handleResponse(response, input, resolve, reject))
            .catch(error => handleFetchError(error, reject));
    }

    // Function to handle the response
    function handleResponse(response, input, resolve, reject) {
        response.clone().blob()
            .then(blob => processBlob(blob, input, response, resolve, reject))
            .catch(error => handleBlobError(error, reject));
    }

    // Function to process the blob
    function processBlob(blob, input, response, resolve, reject) {
        const url = new URL(input, window.location.origin);
        const conversationId = url.searchParams.get('conversation_id') || '';
        const messageId = url.searchParams.get('message_id') || '';
        const name = document.querySelector(`[data-message-id="${messageId}"]`).innerText;

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

    // Function to handle fetch errors
    function handleFetchError(error, reject) {
        console.error('Fetch error:', error);
        reject(error);
        processing = false;
        processQueue();
    }

    // Override the fetch function
    window.fetch = function(input, init) {
        if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
            const url = new URL(input, window.location.origin);
            const conversationId = url.searchParams.get('conversation_id') || '';
            const messageId = url.searchParams.get('message_id') || '';

            if (window.__downloadedMessageIDs && window.__downloadedMessageIDs.includes(messageId)) {
                console.log(`Combination ${key} already processed, fetch aborted.`);
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
