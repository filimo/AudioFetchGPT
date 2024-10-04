 (function() {
     console.log('Start handling /backend-api/synthesize')

     var originalFetch = window.fetch;

     window.fetch = function(input, init) {
         if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
             // Asynchronous operation
             return originalFetch(input, init).then(response => {
                 response.clone().blob().then(blob => {
                     // Asynchronous reading of blob data
                     var reader = new FileReader();
                     reader.onloadend = function() {
                         // Asynchronous message sending to native code
                         window.webkit.messageHandlers.audioHandler.postMessage({
                             // ...
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

     // Comment:
     // Asynchronous operations are used here to handle network requests without blocking the main execution thread.
     // This allows the web interface to remain responsive while loading audio data.
     // Using Promise and .then() ensures sequential execution of asynchronous operations.
 })();
