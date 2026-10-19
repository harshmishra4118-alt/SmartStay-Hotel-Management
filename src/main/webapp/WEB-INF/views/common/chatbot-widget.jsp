<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- In-App Rule-Based FAQ Chatbot Widget -->
<div class="chatbot-widget-container no-print">
    <!-- Chat Window -->
    <div class="chatbot-window" id="chatbotWindow">
        <div class="chatbot-header">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-robot text-gold fs-5"></i>
                <div>
                    <h6 class="mb-0 text-white font-serif">AuraStay Concierge</h6>
                    <small class="text-white-50" style="font-size: 0.7rem;">Rule-Based Smart Assistant</small>
                </div>
            </div>
            <button type="button" class="btn btn-sm text-white" id="chatbotClose" aria-label="Close">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>

        <div class="chatbot-messages" id="chatbotMessages">
            <div class="chat-bubble-bot">
                Hello! Welcome to AuraStay Luxury Suites. How may I assist your stay today?
            </div>
            <div class="mt-2 d-flex flex-wrap gap-1">
                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.75rem;" onclick="document.getElementById('chatbotInput').value='What are the check-in and check-out timings?'; document.getElementById('chatbotSend').click();">
                    Check-in hours
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.75rem;" onclick="document.getElementById('chatbotInput').value='Is breakfast included?'; document.getElementById('chatbotSend').click();">
                    Breakfast
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.75rem;" onclick="document.getElementById('chatbotInput').value='What is the cancellation policy?'; document.getElementById('chatbotSend').click();">
                    Cancellation policy
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.75rem;" onclick="document.getElementById('chatbotInput').value='Is airport shuttle available?'; document.getElementById('chatbotSend').click();">
                    Airport shuttle
                </button>
            </div>
        </div>

        <div class="chatbot-input-area">
            <input type="text" class="form-control form-control-sm" id="chatbotInput" placeholder="Ask about timings, dining, pool..." autocomplete="off">
            <button type="button" class="btn btn-gold btn-sm px-3" id="chatbotSend">
                <i class="bi bi-send-fill"></i>
            </button>
        </div>
    </div>

    <!-- Toggle Button -->
    <div class="chatbot-toggle-btn" id="chatbotToggle" title="Chat with AuraStay Concierge">
        <i class="bi bi-chat-dots-fill"></i>
    </div>
</div>
