import React, { useState } from 'react';
import { Home, User, Users, Search, Bell, MessageCircle, Plus, Minus, MapPin, ChevronDown, Filter, X, Navigation, ChevronRight, Star } from 'lucide-react';

const ImprovedCompatibilityWireframe = () => {
  const [showMoreFilters, setShowMoreFilters] = useState(true);
  const [showAvailabilityPopup, setShowAvailabilityPopup] = useState(true);
  const [showCompatibilityDetails, setShowCompatibilityDetails] = useState(false);
  
  return (
    <div className="w-full max-w-md mx-auto bg-gray-50" style={{ height: '640px', width: '360px', position: 'relative' }}>
      {/* Status Bar */}
      <div className="bg-gray-50 text-black p-4 text-base flex justify-between items-center">
        <span className="font-medium">9:41 AM</span>
      </div>
      
      {/* Header with Title and View Toggle */}
      <div className="px-4 py-2 flex justify-between items-center">
        <h1 className="text-2xl font-bold">
          See & Meet
        </h1>
        <button className="rounded-full bg-blue-500 px-3 py-1 text-white text-sm flex items-center">
          <span>List View</span>
        </button>
      </div>
      
      {/* My Availability Status */}
      <div 
        className="mx-4 mb-2 bg-white rounded-full px-3 py-1.5 shadow-sm flex items-center justify-between border border-gray-200"
        onClick={() => setShowAvailabilityPopup(true)}
      >
        <div className="flex items-center">
          <div className="w-4 h-4 rounded-full bg-green-500 mr-2"></div>
          <span className="text-sm font-medium">You're available now</span>
        </div>
        <span className="text-xs text-blue-500">Change</span>
      </div>
      
      {/* Filter Pills */}
      <div className="px-4 py-2 flex space-x-2 overflow-x-auto">
        <button className="bg-blue-500 text-white px-3 py-1.5 rounded-full text-xs font-medium flex items-center">
          <span>1 mile</span>
          <ChevronDown size={12} className="ml-1" />
        </button>
        <button className="bg-gray-200 text-gray-700 px-3 py-1.5 rounded-full text-xs font-medium flex items-center">
          <span>Interests</span>
          <ChevronDown size={12} className="ml-1" />
        </button>
        <button className="bg-gray-200 text-gray-700 px-3 py-1.5 rounded-full text-xs font-medium flex items-center">
          <span>Now</span>
          <ChevronDown size={12} className="ml-1" />
        </button>
        <button 
          className="bg-green-100 text-green-700 px-3 py-1.5 rounded-full text-xs font-medium flex items-center"
          onClick={() => setShowMoreFilters(!showMoreFilters)}
        >
          <Filter size={12} className="mr-1" />
          <span>More</span>
        </button>
      </div>
      
      {/* Availability Popup */}
      {showAvailabilityPopup && (
        <div className="absolute inset-0 bg-black bg-opacity-50 z-30 flex items-center justify-center px-6">
          <div className="bg-white rounded-xl w-5/6 p-4">
            <div className="flex justify-between items-center mb-3">
              <h3 className="font-bold text-lg">Set Your Availability</h3>
              <button onClick={() => setShowAvailabilityPopup(false)}>
                <X size={20} className="text-gray-500" />
              </button>
            </div>
            
            <div className="space-y-2 mb-4">
              <button className="w-full flex items-center p-2 rounded-lg bg-green-50 border border-green-200">
                <div className="w-6 h-6 rounded-full bg-green-500 mr-2.5"></div>
                <span className="font-medium">Available now</span>
              </button>
              
              <button className="w-full flex items-center p-2 rounded-lg bg-white border border-gray-200">
                <div className="w-6 h-6 rounded-full bg-yellow-400 mr-2.5 flex items-center justify-center text-white font-bold text-xs">
                  15
                </div>
                <span className="font-medium">Available in 15 minutes</span>
              </button>
              
              <button className="w-full flex items-center p-2 rounded-lg bg-white border border-gray-200">
                <div className="w-6 h-6 rounded-full bg-yellow-400 mr-2.5 flex items-center justify-center text-white font-bold text-xs">
                  30
                </div>
                <span className="font-medium">Available in 30 minutes</span>
              </button>
              
              <button className="w-full flex items-center p-2 rounded-lg bg-white border border-gray-200">
                <div className="w-6 h-6 rounded-full bg-gray-400 mr-2.5 flex items-center justify-center text-white">
                  <X size={14} />
                </div>
                <span className="font-medium">Not available</span>
              </button>
            </div>
            
            <div className="flex space-x-2">
              <button 
                className="flex-1 bg-gray-200 py-2 rounded-lg font-medium"
                onClick={() => setShowAvailabilityPopup(false)}
              >
                Cancel
              </button>
              <button 
                className="flex-1 bg-blue-500 text-white py-2 rounded-lg font-medium"
                onClick={() => setShowAvailabilityPopup(false)}
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* More Filters Panel */}
      {showMoreFilters && (
        <div className="px-4 py-3 bg-white shadow-md rounded-lg border border-gray-200 mx-4 z-20 absolute left-0 right-0">
          <div className="flex justify-between items-center mb-3">
            <h3 className="font-bold">Additional Filters</h3>
            <button onClick={() => setShowMoreFilters(false)}>
              <X size={18} className="text-gray-500" />
            </button>
          </div>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-700 block mb-2">Compatibility</label>
              <div className="flex items-center justify-between px-1">
                <span className="text-xs text-gray-500">Any</span>
                <span className="text-xs text-gray-500">High Match</span>
              </div>
              <input
                type="range"
                min="0"
                max="100"
                defaultValue="70"
                className="w-full h-1 bg-gray-200 rounded-lg appearance-none cursor-pointer range-lg"
              />
              <div className="flex items-center justify-between mt-1 px-1">
                <span className="text-xs text-gray-700">Min: 70%</span>
              </div>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700 block mb-1">Activity Preferences</label>
              <div className="flex flex-wrap gap-2">
                <button className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">Coffee</button>
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">Sports</button>
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">Food</button>
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">Movies</button>
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">Outdoors</button>
              </div>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700 block mb-1">Connection Status</label>
              <div className="flex gap-2">
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">New People</button>
                <button className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs">Connected Before</button>
              </div>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700 block mb-1">Verified Users</label>
              <div className="flex items-center">
                <input type="checkbox" id="verified" className="mr-2" />
                <label htmlFor="verified" className="text-sm">Show only NFC verified users</label>
              </div>
            </div>
            
            <button className="w-full bg-blue-500 text-white py-1.5 rounded-full text-sm font-medium mt-2">
              Apply Filters
            </button>
          </div>
        </div>
      )}
      
      {/* Map Area */}
      <div className="relative" style={{ height: 'calc(100% - 228px)' }}>
        <div className="absolute inset-0 bg-gray-200">
          {/* Map will go here in the actual app */}
          
          {/* My Location Indicator */}
          <div className="absolute left-1/2 bottom-1/3 transform -translate-x-1/2">
            <div className="w-8 h-8 rounded-full bg-blue-500 border-4 border-white shadow-lg flex items-center justify-center">
              <div className="w-2 h-2 bg-white rounded-full"></div>
            </div>
            <div className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full bg-white flex items-center justify-center shadow-sm">
              <span className="text-blue-500 text-xs font-bold">Me</span>
            </div>
          </div>
          
          {/* User Markers with compatibility halos */}
          <div className="absolute left-1/3 top-1/4">
            <div className="relative">
              {/* Green halo for high compatibility */}
              <div className="absolute inset-0 w-14 h-14 -m-1 rounded-full bg-green-200 opacity-40"></div>
              <div className="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold shadow-md">
                AK
              </div>
              <div className="absolute -top-2 -right-2 w-5 h-5 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
          </div>
          
          <div className="absolute left-1/4 top-2/5">
            <div className="relative">
              {/* Green halo for high compatibility */}
              <div className="absolute inset-0 w-14 h-14 -m-1 rounded-full bg-green-200 opacity-40"></div>
              <div className="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold shadow-md">
                SK
              </div>
              <div className="absolute -top-2 -right-2 w-5 h-5 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
          </div>
          
          <div className="absolute right-1/4 top-1/3">
            <div className="relative">
              {/* Yellow halo for medium compatibility */}
              <div className="absolute inset-0 w-14 h-14 -m-1 rounded-full bg-yellow-200 opacity-40"></div>
              <div className="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold shadow-md">
                MJ
              </div>
              <div className="absolute -top-2 -right-2 w-5 h-5 bg-yellow-400 rounded-full border-2 border-white flex items-center justify-center">
                <span className="text-white text-xs font-bold">5</span>
              </div>
            </div>
          </div>
          
          <div className="absolute left-2/5 bottom-1/4">
            <div className="relative">
              {/* Orange halo for lower compatibility */}
              <div className="absolute inset-0 w-14 h-14 -m-1 rounded-full bg-orange-200 opacity-40"></div>
              <div className="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold shadow-md opacity-60">
                JD
              </div>
              <div className="absolute -top-2 -right-2 w-5 h-5 bg-gray-500 rounded-full border-2 border-white"></div>
            </div>
          </div>
          
          {/* Map Controls */}
          <div className="absolute right-4 top-1/4 flex flex-col space-y-2">
            <button className="w-8 h-8 rounded-full bg-white shadow-md flex items-center justify-center">
              <Plus size={16} color="#374151" />
            </button>
            <button className="w-8 h-8 rounded-full bg-white shadow-md flex items-center justify-center">
              <Minus size={16} color="#374151" />
            </button>
            <button className="w-8 h-8 rounded-full bg-white shadow-md flex items-center justify-center">
              <MapPin size={16} color="#374151" />
            </button>
          </div>
          
          {/* Map Legend */}
          <div className="absolute left-4 bottom-4 bg-white rounded-lg shadow-md p-2">
            <div className="text-xs font-medium text-gray-700 mb-1">Compatibility</div>
            <div className="space-y-1">
              <div className="flex items-center">
                <div className="w-3 h-3 bg-green-200 rounded-full mr-1.5"></div>
                <span className="text-xs">High match</span>
              </div>
              <div className="flex items-center">
                <div className="w-3 h-3 bg-yellow-200 rounded-full mr-1.5"></div>
                <span className="text-xs">Medium match</span>
              </div>
              <div className="flex items-center">
                <div className="w-3 h-3 bg-orange-200 rounded-full mr-1.5"></div>
                <span className="text-xs">Lower match</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      {/* Selected User Card with Compatibility Score */}
      <div className="absolute bottom-16 left-0 right-0 px-4">
        <div className="bg-white rounded-xl p-3 shadow-md">
          <div className="flex items-center">
            <div className="w-12 h-12 bg-gray-300 rounded-full mr-3 relative">
              {/* Subtle progress ring */}
              <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="48" fill="none" stroke="#e5e7eb" strokeWidth="4" />
                <circle 
                  cx="50" 
                  cy="50" 
                  r="48" 
                  fill="none" 
                  stroke="#22c55e" 
                  strokeWidth="4" 
                  strokeDasharray={`${87 * 3.14}`} 
                  strokeDashoffset="0" 
                  strokeLinecap="round"
                  transform="rotate(-90 50 50)"
                />
              </svg>
            </div>
            <div className="flex-grow">
              <div className="flex items-center" onClick={() => setShowCompatibilityDetails(true)}>
                <h3 className="font-bold">Sarah K.</h3>
                <div className="ml-2 w-3 h-3 bg-green-500 rounded-full"></div>
                <div className="ml-2 flex items-center">
                  <Star size={14} className="text-green-500 mr-0.5 fill-green-500" />
                  <span className="text-sm font-medium text-green-700">87%</span>
                  <ChevronRight size={14} className="text-gray-400 ml-1" />
                </div>
              </div>
              <div className="flex items-center">
                <MapPin size={12} className="text-gray-500 mr-1" />
                <span className="text-gray-600 text-xs">0.3 miles away</span>
              </div>
              <div className="flex mt-1 space-x-2">
                <span className="text-blue-500 text-xs bg-blue-50 px-2 py-0.5 rounded-full">Tennis</span>
                <span className="text-blue-500 text-xs bg-blue-50 px-2 py-0.5 rounded-full">Coffee</span>
              </div>
            </div>
            <button className="bg-blue-500 text-white px-4 py-1.5 rounded-full text-sm font-medium">
              Connect
            </button>
          </div>
        </div>
      </div>

      {/* Compatibility Details Popup */}
      {showCompatibilityDetails && (
        <div className="absolute inset-0 bg-black bg-opacity-50 z-30 flex items-center justify-center px-6">
          <div className="bg-white rounded-xl w-full p-4">
            <div className="flex justify-between items-center mb-3">
              <h3 className="font-bold text-lg">Compatibility with Sarah</h3>
              <button onClick={() => setShowCompatibilityDetails(false)}>
                <X size={20} className="text-gray-500" />
              </button>
            </div>

            {/* Overall Score */}
            <div className="flex items-center justify-center mb-4">
              <div className="w-20 h-20 rounded-full flex items-center justify-center relative">
                <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="44" fill="none" stroke="#e5e7eb" strokeWidth="8" />
                  <circle 
                    cx="50" 
                    cy="50" 
                    r="44" 
                    fill="none" 
                    stroke="#22c55e" 
                    strokeWidth="8" 
                    strokeDasharray={`${87 * 3.14 / 100 * 8.8}`} 
                    strokeDashoffset="0" 
                    strokeLinecap="round"
                    transform="rotate(-90 50 50)"
                  />
                </svg>
                <span className="text-2xl font-bold text-gray-800">87%</span>
              </div>
            </div>

            {/* Compatibility Breakdown */}
            <h4 className="font-medium text-gray-700 mb-2">Compatibility Breakdown</h4>
            <div className="space-y-3 mb-4">
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-sm font-medium">Shared Interests</span>
                  <span className="text-sm font-bold text-green-600">95%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-1.5">
                  <div className="bg-green-500 h-1.5 rounded-full" style={{ width: '95%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-sm font-medium">Activity Preferences</span>
                  <span className="text-sm font-bold text-green-600">90%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-1.5">
                  <div className="bg-green-500 h-1.5 rounded-full" style={{ width: '90%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-sm font-medium">Location Proximity</span>
                  <span className="text-sm font-bold text-green-600">85%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-1.5">
                  <div className="bg-green-500 h-1.5 rounded-full" style={{ width: '85%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-sm font-medium">Availability Match</span>
                  <span className="text-sm font-bold text-yellow-600">75%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-1.5">
                  <div className="bg-yellow-500 h-1.5 rounded-full" style={{ width: '75%' }}></div>
                </div>
              </div>
            </div>

            {/* Common Interests */}
            <h4 className="font-medium text-gray-700 mb-2">Common Interests</h4>
            <div className="flex flex-wrap gap-2 mb-4">
              <span className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">Coffee</span>
              <span className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">Tennis</span>
              <span className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">Books</span>
              <span className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">Movies</span>
            </div>

            <button 
              className="w-full bg-blue-500 text-white py-2 rounded-lg font-medium"
              onClick={() => setShowCompatibilityDetails(false)}
            >
              Got it
            </button>
          </div>
        </div>
      )}
      
      {/* Bottom Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex justify-around py-2">
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <Home size={24} color="#9CA3AF" />
          <span className="text-xs text-gray-500 mt-1">Home</span>
        </button>
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <Users size={24} color="#3B82F6" />
          <span className="text-xs text-blue-500 font-medium mt-1">See & Meet</span>
        </button>
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <User size={24} color="#9CA3AF" />
          <span className="text-xs text-gray-500 mt-1">Profile</span>
        </button>
      </div>
    </div>
  );
};

export default ImprovedCompatibilityWireframe;
