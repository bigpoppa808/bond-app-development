import React, { useState } from 'react';
import { Home, User, Users, Search, Bell, MessageCircle, Plus, MapPin, Clock, Calendar, ChevronLeft, X, ChevronDown, Check, Coffee, Music, ChevronRight } from 'lucide-react';

const ImprovedHomeEventWireframe = () => {
  const [showEventCreation, setShowEventCreation] = useState(false);
  
  return (
    <div className="w-full max-w-md mx-auto bg-gray-50" style={{ height: '640px', width: '360px', position: 'relative' }}>
      {!showEventCreation ? (
        // Home Page
        <>
          {/* Status Bar */}
          <div className="bg-gray-50 text-black p-4 text-base flex justify-between items-center">
            <span className="font-medium">9:41 AM</span>
          </div>
          
          {/* Header */}
          <div className="px-4 py-2 flex justify-between items-center">
            <h1 className="text-2xl font-bold">
              Hi, John <span>👋</span>
            </h1>
            <div className="flex items-center space-x-4">
              <button className="p-1">
                <Search size={24} color="#374151" />
              </button>
              <button className="p-1 relative">
                <Bell size={24} color="#374151" />
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center text-white text-xs">
                  3
                </div>
              </button>
              <button className="p-1 relative">
                <MessageCircle size={24} color="#374151" />
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center text-white text-xs">
                  2
                </div>
              </button>
            </div>
          </div>
          
          {/* Content */}
          <div className="overflow-y-auto pb-16" style={{ height: 'calc(100% - 108px)' }}>
            {/* Today's Plans Card */}
            <div className="px-4 mb-5">
              <div className="bg-blue-50 rounded-xl p-4">
                <h2 className="font-bold text-lg mb-2">Today's Plans</h2>
                <div className="flex items-center">
                  <span className="mr-2">🎾</span>
                  <span className="text-gray-800">Tennis with Sarah at 3:00 PM</span>
                </div>
              </div>
            </div>
            
            {/* Happening Nearby - Improved Design */}
            <div className="mb-5">
              <div className="px-4 flex justify-between items-center mb-3">
                <h2 className="font-bold text-xl">Happening Nearby</h2>
                <button className="text-blue-500 text-sm font-medium">See All</button>
              </div>
              
              <div className="pl-4 overflow-x-auto">
                <div className="flex space-x-4 pb-2 pr-4" style={{ minWidth: 'max-content' }}>
                  <div className="bg-white rounded-xl p-3 shadow-sm" style={{ width: '180px' }}>
                    <div className="flex items-center mb-1">
                      <div className="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center mr-2">
                        <span className="text-lg">🏃</span>
                      </div>
                      <div className="flex-grow">
                        <h3 className="font-bold text-base">Group Run</h3>
                      </div>
                    </div>
                    <div className="space-y-1 mb-2">
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPin size={14} className="mr-1 flex-shrink-0" />
                        <span className="truncate">0.3 miles away</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Clock size={14} className="mr-1 flex-shrink-0" />
                        <span>Starting in 30 mins</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium text-gray-700">3 spots left</span>
                      <button className="bg-blue-500 text-white text-xs font-medium px-3 py-1 rounded-full">
                        Join
                      </button>
                    </div>
                  </div>
                  
                  <div className="bg-white rounded-xl p-3 shadow-sm" style={{ width: '180px' }}>
                    <div className="flex items-center mb-1">
                      <div className="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center mr-2">
                        <Coffee size={18} className="text-blue-600" />
                      </div>
                      <div className="flex-grow">
                        <h3 className="font-bold text-base">Coffee Chat</h3>
                      </div>
                    </div>
                    <div className="space-y-1 mb-2">
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPin size={14} className="mr-1 flex-shrink-0" />
                        <span className="truncate">0.5 miles away</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Clock size={14} className="mr-1 flex-shrink-0" />
                        <span>Starting in 1 hour</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium text-gray-700">2 spots left</span>
                      <button className="bg-blue-500 text-white text-xs font-medium px-3 py-1 rounded-full">
                        Join
                      </button>
                    </div>
                  </div>
                  
                  <div className="bg-white rounded-xl p-3 shadow-sm" style={{ width: '180px' }}>
                    <div className="flex items-center mb-1">
                      <div className="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center mr-2">
                        <Music size={18} className="text-purple-600" />
                      </div>
                      <div className="flex-grow">
                        <h3 className="font-bold text-base">Live Jazz</h3>
                      </div>
                    </div>
                    <div className="space-y-1 mb-2">
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPin size={14} className="mr-1 flex-shrink-0" />
                        <span className="truncate">1.2 miles away</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Clock size={14} className="mr-1 flex-shrink-0" />
                        <span>Starting in 2 hours</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium text-gray-700">5 spots left</span>
                      <button className="bg-blue-500 text-white text-xs font-medium px-3 py-1 rounded-full">
                        Join
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Category Filters */}
            <div className="px-4 mb-4 flex space-x-2 overflow-x-auto">
              <button className="bg-blue-500 text-white px-4 py-2 rounded-full text-sm font-medium">
                All
              </button>
              <button className="bg-gray-200 text-gray-800 px-4 py-2 rounded-full text-sm font-medium">
                Sports
              </button>
              <button className="bg-gray-200 text-gray-800 px-4 py-2 rounded-full text-sm font-medium">
                Social
              </button>
              <button className="bg-gray-200 text-gray-800 px-4 py-2 rounded-full text-sm font-medium">
                Food
              </button>
              <button className="bg-gray-200 text-gray-800 px-4 py-2 rounded-full text-sm font-medium">
                More
              </button>
            </div>
            
            {/* Activity Feed */}
            <div className="px-4">
              <h2 className="font-bold text-xl mb-3">Activity Feed</h2>
              
              {/* Activity Cards */}
              <div className="space-y-4">
                <div className="bg-white rounded-xl p-4 shadow-sm">
                  <div className="flex items-center mb-3">
                    <div className="w-10 h-10 bg-gray-300 rounded-full mr-3"></div>
                    <div>
                      <h3 className="font-bold">Sarah Kim</h3>
                      <p className="text-gray-500 text-xs">10 mins ago • 0.5 miles away</p>
                    </div>
                  </div>
                  
                  <div className="mb-3">
                    <div className="flex items-center mb-1">
                      <span className="text-xl mr-2">🚶</span>
                      <span className="font-bold">Evening Walk</span>
                    </div>
                    <p className="text-gray-800">Anyone up for a relaxing walk around Lake Park?</p>
                  </div>
                  
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-gray-600 mb-1">⏰ Today, 6:00 PM</p>
                      <p className="text-gray-600">👥 2/4 spots filled</p>
                    </div>
                    <button className="bg-blue-500 text-white px-5 py-2 rounded-full font-medium">
                      Join
                    </button>
                  </div>
                </div>
                
                <div className="bg-white rounded-xl p-4 shadow-sm">
                  <div className="flex items-center mb-3">
                    <div className="w-10 h-10 bg-gray-300 rounded-full mr-3"></div>
                    <div>
                      <h3 className="font-bold">Michael Chen</h3>
                      <p className="text-gray-500 text-xs">25 mins ago • 0.8 miles away</p>
                    </div>
                  </div>
                  
                  <div className="mb-3">
                    <div className="flex items-center mb-1">
                      <span className="text-xl mr-2">📚</span>
                      <span className="font-bold">Book Club</span>
                    </div>
                    <p className="text-gray-800">Discussing "The Midnight Library" at Coastal Coffee. Beginners welcome!</p>
                  </div>
                  
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-gray-600 mb-1">⏰ Tomorrow, 5:30 PM</p>
                      <p className="text-gray-600">👥 3/6 spots filled</p>
                    </div>
                    <button className="bg-blue-500 text-white px-5 py-2 rounded-full font-medium">
                      Join
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          {/* Create Button (Fixed) */}
          <div className="absolute bottom-20 right-4">
            <button 
              className="w-14 h-14 bg-blue-500 rounded-full flex items-center justify-center shadow-lg"
              onClick={() => setShowEventCreation(true)}
            >
              <Plus size={24} color="white" />
            </button>
          </div>
          
          {/* Bottom Tab Bar */}
          <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex justify-around py-2">
            <button className="p-1 flex flex-col items-center justify-center w-20">
              <Home size={24} color="#3B82F6" />
              <span className="text-xs text-blue-500 font-medium mt-1">Home</span>
            </button>
            <button className="p-1 flex flex-col items-center justify-center w-20">
              <Users size={24} color="#9CA3AF" />
              <span className="text-xs text-gray-500 mt-1">See & Meet</span>
            </button>
            <button className="p-1 flex flex-col items-center justify-center w-20">
              <User size={24} color="#9CA3AF" />
              <span className="text-xs text-gray-500 mt-1">Profile</span>
            </button>
          </div>
        </>
      ) : (
        // Event Creation Page
        <>
          {/* Status Bar */}
          <div className="bg-gray-50 text-black p-4 text-base flex justify-between items-center">
            <span className="font-medium">9:41 AM</span>
          </div>
          
          {/* Header */}
          <div className="px-4 py-2 flex items-center border-b border-gray-200">
            <button className="mr-2" onClick={() => setShowEventCreation(false)}>
              <ChevronLeft size={24} color="#374151" />
            </button>
            <h1 className="text-xl font-bold flex-grow">Create Activity</h1>
            <button className="bg-blue-500 px-4 py-1.5 rounded-full text-white text-sm font-medium">
              Post
            </button>
          </div>
          
          {/* Content */}
          <div className="overflow-y-auto p-4" style={{ height: 'calc(100% - 108px)' }}>
            {/* Activity Title */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-1">Activity Title</label>
              <input 
                type="text" 
                className="w-full p-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="What would you like to do?"
              />
            </div>
            
            {/* Activity Type */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-2">Activity Type</label>
              <div className="grid grid-cols-4 gap-2">
                <button className="flex flex-col items-center p-2 bg-blue-50 border border-blue-200 rounded-lg">
                  <Coffee size={20} className="text-blue-600 mb-1" />
                  <span className="text-xs text-gray-800">Coffee</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xl mb-1">🍽️</span>
                  <span className="text-xs text-gray-800">Food</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xl mb-1">🏃</span>
                  <span className="text-xs text-gray-800">Sports</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <Music size={20} className="text-gray-600 mb-1" />
                  <span className="text-xs text-gray-800">Music</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xl mb-1">🏕️</span>
                  <span className="text-xs text-gray-800">Outdoor</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xl mb-1">📚</span>
                  <span className="text-xs text-gray-800">Books</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xl mb-1">🎬</span>
                  <span className="text-xs text-gray-800">Movies</span>
                </button>
                <button className="flex flex-col items-center p-2 bg-gray-100 border border-gray-200 rounded-lg">
                  <span className="text-xs text-gray-800">More</span>
                </button>
              </div>
            </div>
            
            {/* Description */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-1">Description</label>
              <textarea 
                className="w-full p-3 border border-gray-300 rounded-xl h-24 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Tell others what this activity is about..."
              ></textarea>
            </div>
            
            {/* Date & Time */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-2">Date & Time</label>
              <div className="flex space-x-3">
                <div className="flex-1">
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                      <Calendar size={18} className="text-gray-500" />
                    </div>
                    <input 
                      type="text" 
                      className="w-full p-3 pl-10 border border-gray-300 rounded-xl"
                      placeholder="Date"
                      defaultValue="Today"
                    />
                  </div>
                </div>
                <div className="flex-1">
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                      <Clock size={18} className="text-gray-500" />
                    </div>
                    <input 
                      type="text" 
                      className="w-full p-3 pl-10 border border-gray-300 rounded-xl"
                      placeholder="Time"
                      defaultValue="7:00 PM"
                    />
                  </div>
                </div>
              </div>
            </div>
            
            {/* Location */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-1">Location</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                  <MapPin size={18} className="text-gray-500" />
                </div>
                <input 
                  type="text" 
                  className="w-full p-3 pl-10 border border-gray-300 rounded-xl"
                  placeholder="Where will this activity take place?"
                />
              </div>
            </div>
            
            {/* Capacity */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-1">Max Participants</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                  <Users size={18} className="text-gray-500" />
                </div>
                <select className="w-full p-3 pl-10 border border-gray-300 rounded-xl bg-white appearance-none pr-8">
                  <option>2 people</option>
                  <option>3 people</option>
                  <option>4 people</option>
                  <option>5 people</option>
                  <option>6+ people</option>
                </select>
                <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <ChevronDown size={18} className="text-gray-500" />
                </div>
              </div>
            </div>
            
            {/* Visibility */}
            <div className="mb-5">
              <label className="block font-medium text-gray-700 mb-2">Visibility</label>
              <div className="space-y-2">
                <div className="flex items-center p-3 bg-blue-50 border border-blue-200 rounded-xl">
                  <input type="radio" name="visibility" id="public" className="mr-3" checked />
                  <div className="flex-grow">
                    <label htmlFor="public" className="font-medium">Public</label>
                    <p className="text-gray-600 text-sm">Anyone nearby can see and join</p>
                  </div>
                  <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
                    <Check size={16} className="text-blue-600" />
                  </div>
                </div>
                
                <div className="flex items-center p-3 bg-white border border-gray-200 rounded-xl">
                  <input type="radio" name="visibility" id="friends" className="mr-3" />
                  <div className="flex-grow">
                    <label htmlFor="friends" className="font-medium">Connections Only</label>
                    <p className="text-gray-600 text-sm">Only people you've connected with</p>
                  </div>
                </div>
                
                <div className="flex items-center p-3 bg-white border border-gray-200 rounded-xl">
                  <input type="radio" name="visibility" id="private" className="mr-3" />
                  <div className="flex-grow">
                    <label htmlFor="private" className="font-medium">Invite Only</label>
                    <p className="text-gray-600 text-sm">Only visible to people you invite</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default ImprovedHomeEventWireframe;
