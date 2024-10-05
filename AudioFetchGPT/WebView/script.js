(function() {
    console.log('Start handling /backend-api/synthesize')

    var originalFetch = window.fetch;

    window.fetch = function(input, init) {
        if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
            // Parse URL to extract parameters
            const url = new URL(input, window.location.origin);
            let conversationId = url.searchParams.get('conversation_id') || '';
            let messageId = url.searchParams.get('message_id') || '';
            let name = document.querySelector(`[data-message-id="${messageId}"]`).innerText;

            return originalFetch(input, init).then(response => {
                response.clone().blob().then(blob => {
                    var reader = new FileReader();
                    reader.onloadend = function() {
                        window.webkit.messageHandlers.audioHandler.postMessage({
                           conversationId: conversationId,
                           messageId: messageId,
                           audioData: reader.result,
                           name: name
                       });
                    };
                    reader.readAsDataURL(blob);
                });
                return response;
            }).catch(error => {
                console.error('Fetch error:', error);
                throw error;
            });
        }
        return originalFetch(input, init);
    };
})();
