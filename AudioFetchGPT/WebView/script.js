 (function() {
     console.log('Start handling /backend-api/synthesize')

     var originalFetch = window.fetch;
     var dataTestId = '';

     // Функция для навешивания обработчика на кнопки
     function addClickHandlerToButtons() {
         const buttons = document.querySelectorAll('button[aria-label="Read aloud"]');

         buttons.forEach(button => {
             // Проверяем, не был ли уже навешен обработчик
             if (!button.dataset.handlerAttached) {
                 button.addEventListener('click', function() {
                     dataTestId = button.closest('article').getAttribute('data-testid');
                 });

                 // Устанавливаем флаг, чтобы не навешивать обработчик повторно
                 button.dataset.handlerAttached = 'true';
             }
         });
     }

     document.addEventListener('DOMContentLoaded', function () {
         // Наблюдатель за изменениями в DOM
         const observer = new MutationObserver((mutationsList) => {
         for (let mutation of mutationsList) {
             if (mutation.type === 'childList') {
                 // Если были добавлены новые узлы, проверяем их на наличие кнопок
                 addClickHandlerToButtons();
             }
         }
         });

         // Настройки для наблюдателя (следим за изменениями в дочерних элементах)
         const observerConfig = { childList: true, subtree: true };

         // Начинаем отслеживание изменений в документе
         observer.observe(document.body, observerConfig);

         // Навешиваем обработчики на уже существующие кнопки
         addClickHandlerToButtons();
     });

     window.fetch = function(input, init) {
         if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
             return originalFetch(input, init).then(response => {
                 response.clone().blob().then(blob => {
                     var reader = new FileReader();
                     reader.onloadend = function() {
                         window.webkit.messageHandlers.audioHandler.postMessage({
                            dataTestId: dataTestId,
                            audioData: reader.result
                        });
                     };
                     reader.readAsDataURL(blob);
                 });
                 return response;
             });
         }
         return originalFetch(input, init);
     };
 })();
