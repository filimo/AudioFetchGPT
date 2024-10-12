(function() {
    console.log('Start handling /backend-api/synthesize');

    var originalFetch = window.fetch;
    var queue = [];
    var processing = false;

    // function for processing the next requests
    function processQueue() {
        if (queue.length === 0 || processing) {
            return;
        }

        processing = true;
        const { input, init, resolve, reject } = queue.shift();

        originalFetch(input, init)
            .then(response => {
                response.clone().blob().then(blob => {
                    const url = new URL(input, window.location.origin);
                    let conversationId = url.searchParams.get('conversation_id') || '';
                    let messageId = url.searchParams.get('message_id') || '';
                    let name = document.querySelector(`[data-message-id="${messageId}"]`).innerText;

                    var reader = new FileReader();
                    reader.onloadend = function() {
                        window.webkit.messageHandlers.audioHandler.postMessage({
                            conversationId: conversationId,
                            messageId: messageId,
                            audioData: reader.result,
                            name: name
                        });
                        resolve(response);
                        processing = false;
                        processQueue();
                    };
                    reader.readAsDataURL(blob);
                }).catch(error => {
                    console.error('Error reading blob:', error);
                    reject(error);
                    processing = false;
                    processQueue();
                });
            })
            .catch(error => {
                console.error('Fetch error:', error);
                reject(error);
                processing = false;
                processQueue();
            });
    }

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
