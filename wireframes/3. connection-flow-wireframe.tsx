import React, { useState } from 'react';
import { ChevronLeft, MapPin, Coffee, MessageCircle, Zap, Navigation, Clock, Check } from 'lucide-react';

const ConnectionFlowWireframe = () => {
  const [activeTab, setActiveTab] = useState('chat');
  
  return (
    <div className="w-full max-w-md mx-auto bg-gray-50" style={{ height: '640px', width: '360px', position: 'relative' }}>
      {/* Status Bar */}
      <div className="bg-gray-50 text-black p-4 text-base flex justify-between items-center">
        <span className="font-medium">9:41 AM</span>
      </div>
      
      {/* Header */}
      <div className="px-4 py-2 flex items-center border-b border-gray-200">
        <button className="mr-2">
          <ChevronLeft size={24} color="#374151" />
        </button>
        <div className="flex-grow">
          <h1 className="text-xl font-bold">Sarah K.</h1>
          <div className="flex items-center">
            <div className="w-2 h-2 rounded-full bg-green-500 mr-1.5"></div>
            <span className="text-sm text-gray-600">Available now • 0.3 miles away</span>
          </div>
        </div>
        <div className="w-10 h-10 bg-gray-300 rounded-full"></div>
      </div>
      
      {/* Connection Status Banner */}
      <div className="bg-blue-50 p-3 flex items-center justify-between">
        <div className="flex items-center">
          <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-2 text-blue-500">
            <Check size={16} />
          </div>
          <div>
            <h3 className="font-medium text-blue-800">Connection accepted!</h3>
            <p className="text-blue-600 text-xs">Meet in person to earn 100 tokens</p>
          </div>
        </div>
        <button className="bg-blue-500 rounded-lg px-3 py-1 text-white text-sm font-medium">
          Verify Now
        </button>
      </div>
      
      {/* Tab Navigation */}
      <div className="px-4 border-b border-gray-200">
        <div className="flex space-x-6">
          <button 
            className={`py-3 font-medium ${activeTab === 'chat' ? 'text-blue-500 border-b-2 border-blue-500' : 'text-gray-500'}`}
            onClick={() => setActiveTab('chat')}
          >
            Chat
          </button>
          <button 
            className={`py-3 font-medium ${activeTab === 'directions' ? 'text-blue-500 border-b-2 border-blue-500' : 'text-gray-500'}`}
            onClick={() => setActiveTab('directions')}
          >
            Directions
          </button>
          <button 
            className={`py-3 font-medium ${activeTab === 'profile' ? 'text-blue-500 border-b-2 border-blue-500' : 'text-gray-500'}`}
            onClick={() => setActiveTab('profile')}
          >
            Profile
          </button>
        </div>
      </div>
      
      {/* Content Area */}
      <div className="overflow-y-auto" style={{ height: 'calc(100% - 196px)' }}>
        {activeTab === 'chat' && (
          <div className="p-4 h-full flex flex-col">
            <div className="flex-grow space-y-3">
              {/* System Message */}
              <div className="text-center my-2">
                <span className="text-xs bg-gray-100 text-gray-500 px-2 py-1 rounded-full">
                  Today, 9:30 AM
                </span>
              </div>
              
              {/* System Message */}
              <div className="text-center my-2">
                <span className="text-xs bg-gray-100 text-gray-500 px-2 py-1 rounded-full">
                  You connected with Sarah
                </span>
              </div>
              
              {/* Their Message */}
              <div className="flex items-end">
                <div className="max-w-[75%] bg-gray-200 rounded-t-xl rounded-br-xl p-3 text-gray-800">
                  <p>Hi! I saw we both like coffee. Would you like to meet at Lighthouse Cafe nearby?</p>
                </div>
              </div>
              
              {/* Your Message */}
              <div className="flex items-end justify-end">
                <div className="max-w-[75%] bg-blue-500 rounded-t-xl rounded-bl-xl p-3 text-white">
                  <p>Sure, that sounds great! When works for you?</p>
                </div>
              </div>
              
              {/* Their Message */}
              <div className="flex items-end">
                <div className="max-w-[75%] bg-gray-200 rounded-t-xl rounded-br-xl p-3 text-gray-800">
                  <p>I'm free now if that works for you? It's just a 5 minute walk.</p>
                </div>
              </div>
              
              {/* Recommended Meeting Card */}
              <div className="bg-white border border-gray-200 rounded-xl p-3 shadow-sm">
                <div className="flex justify-between items-start mb-2">
                  <h4 className="font-bold">Suggested Meetup</h4>
                  <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">Now</span>
                </div>
                <div className="flex items-center mb-2">
                  <Coffee size={16} className="text-gray-500 mr-2" />
                  <span className="font-medium">Lighthouse Cafe</span>
                </div>
                <div className="flex items-center text-gray-600 text-sm mb-3">
                  <MapPin size={14} className="mr-1" />
                  <span>0.2 miles away</span>
                </div>
                <div className="flex space-x-2">
                  <button className="flex-1 bg-blue-500 text-white py-1.5 rounded-lg text-sm font-medium">
                    Accept
                  </button>
                  <button className="flex-1 bg-gray-200 text-gray-700 py-1.5 rounded-lg text-sm">
                    Suggest Alternative
                  </button>
                </div>
              </div>
            </div>
            
            {/* Message Input */}
            <div className="flex items-center mt-3 border-t border-gray-200 pt-3">
              <input 
                type="text" 
                placeholder="Type a message..."
                className="flex-grow bg-gray-100 rounded-full py-2 px-4 mr-2 focus:outline-none"
              />
              <button className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="22" y1="2" x2="11" y2="13"></line>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
              </button>
            </div>
          </div>
        )}
        
        {activeTab === 'directions' && (
          <div className="p-4 space-y-4">
            {/* Map Preview */}
            <div className="h-52 bg-gray-200 rounded-xl relative">
              {/* This would be an actual map in the final app */}
              <div className="absolute inset-0 flex items-center justify-center text-gray-500">
                Map View
              </div>
              
              {/* Direction indicators */}
              <div className="absolute bottom-3 left-3 right-3 bg-white rounded-lg p-2 shadow-md">
                <div className="flex items-center text-sm">
                  <Navigation size={16} className="text-blue-500 mr-2" />
                  <span className="font-medium">Lighthouse Cafe</span>
                  <span className="mx-1">•</span>
                  <span>5 min walk</span>
                </div>
              </div>
            </div>
            
            {/* Meeting Details */}
            <div className="bg-white rounded-xl border border-gray-200 p-3">
              <h3 className="font-bold mb-2">Meeting Details</h3>
              
              <div className="space-y-3">
                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center mr-2 text-gray-700">
                    <Clock size={16} />
                  </div>
                  <div>
                    <h4 className="font-medium">Today, right now</h4>
                    <p className="text-gray-600 text-sm">Meetup time</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center mr-2 text-gray-700">
                    <MapPin size={16} />
                  </div>
                  <div>
                    <h4 className="font-medium">Lighthouse Cafe</h4>
                    <p className="text-gray-600 text-sm">123 Main Street</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center mr-2 text-gray-700">
                    <Coffee size={16} />
                  </div>
                  <div>
                    <h4 className="font-medium">Coffee Chat</h4>
                    <p className="text-gray-600 text-sm">Chosen activity</p>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Token Reminder */}
            <div className="bg-blue-50 rounded-xl p-3 border border-blue-100">
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-2 text-blue-500">
                  <Zap size={16} />
                </div>
                <div>
                  <h4 className="font-medium text-blue-800">Remember to verify!</h4>
                  <p className="text-blue-600 text-sm">Tap phones to earn 100 Bond tokens</p>
                </div>
              </div>
            </div>
            
            {/* Action Buttons */}
            <div className="space-y-2 pt-2">
              <button className="w-full bg-blue-500 text-white py-2.5 rounded-xl font-medium">
                Open in Maps
              </button>
              <button className="w-full bg-gray-200 text-gray-700 py-2.5 rounded-xl font-medium">
                Reschedule
              </button>
            </div>
          </div>
        )}
        
        {activeTab === 'profile' && (
          <div className="p-4 space-y-4">
            {/* User Info */}
            <div className="flex items-center mb-4">
              <div className="w-16 h-16 bg-gray-300 rounded-full mr-3"></div>
              <div>
                <h2 className="font-bold text-lg">Sarah Kim</h2>
                <p className="text-gray-600 text-sm">Active now</p>
                <div className="flex mt-1 space-x-2">
                  <span className="text-blue-500 text-xs bg-blue-50 px-2 py-0.5 rounded-full">Tennis</span>
                  <span className="text-blue-500 text-xs bg-blue-50 px-2 py-0.5 rounded-full">Coffee</span>
                  <span className="text-blue-500 text-xs bg-blue-50 px-2 py-0.5 rounded-full">Reading</span>
                </div>
              </div>
            </div>
            
            {/* Bio */}
            <div>
              <h3 className="font-bold mb-2">About</h3>
              <p className="text-gray-700">
                Product designer by day, coffee enthusiast always. Love meeting new people and exploring the city. 
                Always up for a good book discussion or finding hidden coffee spots!
              </p>
            </div>
            
            {/* Preferred Activities */}
            <div>
              <h3 className="font-bold mb-2">Preferred Activities</h3>
              <div className="space-y-2">
                <div className="bg-white rounded-lg p-3 shadow-sm flex items-center">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                    <Coffee size={16} color="#1D4ED8" />
                  </div>
                  <div>
                    <h4 className="font-medium">Coffee & Conversations</h4>
                    <p className="text-gray-500 text-xs">Weekday evenings, Weekend mornings</p>
                  </div>
                </div>
                
                <div className="bg-white rounded-lg p-3 shadow-sm flex items-center">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1D4ED8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <circle cx="12" cy="12" r="10"></circle>
                      <path d="M12 6v6l4 2"></path>
                    </svg>
                  </div>
                  <div>
                    <h4 className="font-medium">Tennis Matches</h4>
                    <p className="text-gray-500 text-xs">Weekend afternoons</p>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Verification Reminder */}
            <div className="bg-blue-50 rounded-xl p-3 border border-blue-100">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-2 text-blue-500">
                    <Zap size={16} />
                  </div>
                  <div>
                    <h4 className="font-medium text-blue-800">Not Verified Yet</h4>
                    <p className="text-blue-600 text-xs">Meet in person to verify</p>
                  </div>
                </div>
                <button className="bg-blue-500 px-3 py-1 rounded-lg text-white text-sm font-medium">
                  Verify
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ConnectionFlowWireframe;
