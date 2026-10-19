/**
 * AuraStay Luxury Suites & Resort - Main JavaScript Suite
 * Rule-based FAQ Chatbot, Live Price Calculator, and Admin Charts
 */

document.addEventListener('DOMContentLoaded', function () {

    // 1. Minimum Date Enforcement on Date Inputs
    const checkInInputs = document.querySelectorAll('input[type="date"][name="checkIn"]');
    const checkOutInputs = document.querySelectorAll('input[type="date"][name="checkOut"]');
    const today = new Date().toISOString().split('T')[0];

    checkInInputs.forEach(input => {
        if (!input.value) input.value = today;
        input.min = today;
        input.addEventListener('change', function () {
            const nextDay = new Date(this.value);
            nextDay.setDate(nextDay.getDate() + 1);
            const nextDayStr = nextDay.toISOString().split('T')[0];
            checkOutInputs.forEach(outInput => {
                outInput.min = nextDayStr;
                if (outInput.value <= this.value) {
                    outInput.value = nextDayStr;
                }
            });
            updateLivePricing();
        });
    });

    checkOutInputs.forEach(input => {
        if (!input.value) {
            const tmrw = new Date();
            tmrw.setDate(tmrw.getDate() + 1);
            input.value = tmrw.toISOString().split('T')[0];
        }
        input.addEventListener('change', updateLivePricing);
    });

    // 2. Dynamic Price Calculator on Booking Form
    function updateLivePricing() {
        const checkInEl = document.querySelector('#bookingForm input[name="checkIn"]');
        const checkOutEl = document.querySelector('#bookingForm input[name="checkOut"]');
        const pricePerNightEl = document.querySelector('#roomPricePerNight');

        if (checkInEl && checkOutEl && pricePerNightEl) {
            const checkIn = new Date(checkInEl.value);
            const checkOut = new Date(checkOutEl.value);
            const pricePerNight = parseFloat(pricePerNightEl.value);

            if (!isNaN(checkIn.getTime()) && !isNaN(checkOut.getTime()) && checkOut > checkIn) {
                const diffTime = Math.abs(checkOut - checkIn);
                const nights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                const baseAmount = nights * pricePerNight;
                const taxAmount = baseAmount * 0.12; // 12% GST
                const totalAmount = baseAmount + taxAmount;

                const nightsDisplay = document.querySelector('#calcNights');
                const baseDisplay = document.querySelector('#calcBase');
                const taxDisplay = document.querySelector('#calcTax');
                const totalDisplay = document.querySelector('#calcTotal');

                if (nightsDisplay) nightsDisplay.textContent = nights + (nights === 1 ? ' night' : ' nights');
                if (baseDisplay) baseDisplay.textContent = '₹' + baseAmount.toLocaleString('en-IN', {minimumFractionDigits: 2});
                if (taxDisplay) taxDisplay.textContent = '₹' + taxAmount.toLocaleString('en-IN', {minimumFractionDigits: 2});
                if (totalDisplay) totalDisplay.textContent = '₹' + totalAmount.toLocaleString('en-IN', {minimumFractionDigits: 2});
            }
        }
    }

    updateLivePricing();

    // 3. Auto-Dismiss Alerts
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.classList.add('fade');
            setTimeout(() => alert.remove(), 300);
        }, 5000);
    });

    // 4. Rule-Based FAQ Chatbot
    const chatToggle = document.getElementById('chatbotToggle');
    const chatWindow = document.getElementById('chatbotWindow');
    const chatClose = document.getElementById('chatbotClose');
    const chatInput = document.getElementById('chatbotInput');
    const chatSend = document.getElementById('chatbotSend');
    const chatMessages = document.getElementById('chatbotMessages');

    if (chatToggle && chatWindow) {
        chatToggle.addEventListener('click', () => {
            const isVisible = chatWindow.style.display === 'flex';
            chatWindow.style.display = isVisible ? 'none' : 'flex';
            if (!isVisible && chatInput) chatInput.focus();
        });

        if (chatClose) {
            chatClose.addEventListener('click', () => {
                chatWindow.style.display = 'none';
            });
        }

        function appendMessage(text, isUser, suggestions = []) {
            if (!chatMessages) return;
            const bubble = document.createElement('div');
            bubble.className = isUser ? 'chat-bubble-user' : 'chat-bubble-bot';
            bubble.textContent = text;
            chatMessages.appendChild(bubble);

            if (suggestions && suggestions.length > 0) {
                const suggContainer = document.createElement('div');
                suggContainer.className = 'mt-2 d-flex flex-wrap gap-1';
                suggestions.forEach(s => {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'btn btn-sm btn-outline-secondary py-0 px-2';
                    btn.style.fontSize = '0.75rem';
                    btn.textContent = s;
                    btn.onclick = () => {
                        chatInput.value = s;
                        sendChatMessage();
                    };
                    suggContainer.appendChild(btn);
                });
                chatMessages.appendChild(suggContainer);
            }

            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function sendChatMessage() {
            const query = chatInput.value.trim();
            if (!query) return;

            appendMessage(query, true);
            chatInput.value = '';

            // Post to rule-based chatbot endpoint
            const ctx = window.AURA_CONTEXT_PATH || '';
            fetch(ctx + '/api/chatbot', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: 'query=' + encodeURIComponent(query)
            })
            .then(res => res.json())
            .then(data => {
                setTimeout(() => {
                    appendMessage(data.answer, false, data.suggestedQuestions);
                }, 200);
            })
            .catch(() => {
                appendMessage("I am temporarily unavailable. Please visit our front desk or check our FAQ page.", false);
            });
        }

        if (chatSend && chatInput) {
            chatSend.addEventListener('click', sendChatMessage);
            chatInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') sendChatMessage();
            });
        }
    }
});
