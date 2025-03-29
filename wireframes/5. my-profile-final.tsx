import React, { useState } from 'react';
import { Settings, MapPin, Calendar, MessageCircle, Map, Heart, Users, UserPlus, Zap, Edit, ChevronRight, Home, User, Camera, Bell, Edit2, Shield, X } from 'lucide-react';

const MyProfile = () => {
  const [showDonationModal, setShowDonationModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedInterest, setSelectedInterest] = useState(null);
  
  // Interest details data
  const interestDetails = {
    "Coffee": {
      icon: "☕",
      experience: "8+ years",
      level: "Enthusiast",
      description: "Love exploring specialty coffee shops. Current favorite is pour-over with Ethiopian beans."
    },
    "Tennis": {
      icon: "🎾",
      experience: "5 years",
      level: "Intermediate",
      description: "Play recreationally twice a week. Enjoy both singles and doubles matches."
    },
    "Technology": {
      icon: "💻",
      experience: "12+ years",
      level: "Professional",
      description: "Work as a software developer. Interested in AI, mobile apps, and emerging tech."
    },
    "Food": {
      icon: "🍽️",
      experience: "Lifelong passion",
      level: "Adventurous eater",
      description: "Love trying new restaurants and cuisines. Particularly enjoy spicy food and Asian fusion."
    },
    "Hiking": {
      icon: "🥾",
      experience: "3 years",
      level: "Regular",
      description: "Try to go hiking at least twice a month. Favorite local trail is Eagle Ridge."
    }
  };
  
  return (
    <div style={{ height: '640px', width: '360px', position: 'relative' }} className="bg-gray-50">
      {/* Header */}
      <div className="px-4 py-4 flex justify-between items-center">
        <h1 className="text-2xl font-bold">My Profile</h1>
        <button className="p-1">
          <Settings size={22} color="#374151" />
        </button>
      </div>
      
      {/* Profile Info */}
      <div className="px-4 mb-4">
        <div className="flex items-start">
          <div className="relative mr-4">
            <div className="w-20 h-20 bg-gray-300 rounded-full"></div>
            <div className="absolute bottom-0 right-0 w-6 h-6 bg-green-500 rounded-full border-2 border-white"></div>
            <button className="absolute top-0 right-0 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-sm">
              <Camera size={12} className="text-gray-600" />
            </button>
          </div>
          <div>
            <h2 className="text-xl font-bold">John Davis</h2>
            
            <div className="flex items-center mt-1 mb-1">
              <Zap size={14} className="text-blue-500 mr-1" />
              <span className="text-blue-500 font-medium text-sm">850 Bond Tokens</span>
            </div>
            
            <div className="text-gray-600 text-sm mb-1">
              <MapPin size={14} className="inline mr-1" />
              <span>San Francisco, CA</span>
            </div>
            
            <div className="flex items-center">
              <div className="px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded-full flex items-center">
                <div className="w-2 h-2 rounded-full bg-green-500 mr-1"></div>
                <span>Available now</span>
              </div>
              <button className="ml-2 text-blue-500 text-xs flex items-center" onClick={() => setShowEditModal(true)}>
                <Edit size={10} className="mr-0.5" />
                <span>Edit</span>
              </button>
            </div>
          </div>
        </div>
      </div>
      
      {/* Donor Card */}
      <div 
        className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm border border-green-100 cursor-pointer"
        onClick={() => setShowDonationModal(true)}
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center mr-3">
              <Heart size={18} className="text-green-600" />
            </div>
            <div>
              <h3 className="font-bold">Silver Donor</h3>
              <p className="text-xs text-gray-600">Since May 2024 • $5/month</p>
            </div>
          </div>
          <ChevronRight size={18} className="text-gray-400" />
        </div>
      </div>
      
      {/* About */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <div className="flex justify-between items-center mb-1">
          <h3 className="font-bold text-sm">About</h3>
          <button className="text-blue-500">
            <Edit size={14} color="#3B82F6" />
          </button>
        </div>
        <p className="text-gray-700 text-sm mb-2">
          Tech enthusiast and coffee lover. Always up for a good tennis match or trying new restaurants. Looking to meet interesting people in the city.
        </p>
        <div className="flex flex-wrap gap-1">
          {Object.keys(interestDetails).map(interest => (
            <button 
              key={interest} 
              className="bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full text-xs flex items-center hover:bg-blue-200 transition-colors"
              onClick={() => setSelectedInterest(interest)}
            >
              <span>{interestDetails[interest].icon}</span>
              <span className="ml-1">{interest}</span>
            </button>
          ))}
        </div>
      </div>
      
      {/* My Availability */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <div className="flex justify-between items-center mb-2">
          <h3 className="font-bold text-sm">My Availability</h3>
          <button className="text-blue-500">
            <Edit size={14} color="#3B82F6" />
          </button>
        </div>
        
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Today</span>
            </div>
            <span className="text-gray-600 text-sm">1:00 PM - 5:00 PM</span>
          </div>
          
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Tuesday</span>
            </div>
            <span className="text-gray-600 text-sm">7:00 PM - 9:00 PM</span>
          </div>
          
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Saturday</span>
            </div>
            <span className="text-gray-600 text-sm">10:00 AM - 3:00 PM</span>
          </div>
        </div>
        
        <button className="w-full border border-blue-500 text-blue-500 py-1.5 rounded-lg font-medium mt-3 text-sm">
          Add More Availability
        </button>
      </div>
      
      {/* My Stats */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <h3 className="font-bold text-sm mb-2">My Stats</h3>
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-gray-50 rounded-lg p-2 text-center">
            <div className="text-lg font-bold text-gray-700">23</div>
            <div className="text-xs text-gray-500">Connections</div>
          </div>
          <div className="bg-gray-50 rounded-lg p-2 text-center">
            <div className="text-lg font-bold text-gray-700">15</div>
            <div className="text-xs text-gray-500">Meetings</div>
          </div>
          <div className="bg-gray-50 rounded-lg p-2 text-center">
            <div className="text-lg font-bold text-gray-700">4.9</div>
            <div className="text-xs text-gray-500">Rating</div>
          </div>
        </div>
      </div>
      
      {/* Settings */}
      <div className="mx-4 mb-8">
        <h3 className="text-sm font-bold text-gray-700 mb-2 px-1">Settings</h3>
        <div className="bg-white rounded-xl shadow-sm divide-y divide-gray-100">
          <button className="w-full flex items-center justify-between p-3">
            <span className="text-sm font-medium">Privacy Settings</span>
            <ChevronRight size={16} className="text-gray-400" />
          </button>
          <button className="w-full flex items-center justify-between p-3">
            <span className="text-sm font-medium">Notification Preferences</span>
            <ChevronRight size={16} className="text-gray-400" />
          </button>
          <button 
            className="w-full flex items-center justify-between p-3 text-blue-500"
            onClick={() => setShowDonationModal(true)}
          >
            <span className="text-sm font-medium">Manage Donation</span>
            <ChevronRight size={16} className="text-blue-500" />
          </button>
        </div>
      </div>
      
      {/* Bottom Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex justify-around py-2">
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <Home size={24} color="#9CA3AF" />
          <span className="text-xs text-gray-500 mt-1">Home</span>
        </button>
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <Users size={24} color="#9CA3AF" />
          <span className="text-xs text-gray-500 mt-1">See & Meet</span>
        </button>
        <button className="p-1 flex flex-col items-center justify-center w-20">
          <User size={24} color="#3B82F6" />
          <span className="text-xs text-blue-500 font-medium mt-1">Profile</span>
        </button>
      </div>
      
      {/* Edit Profile Modal */}
      {showEditModal && (
        <div className="absolute inset-0 bg-black bg-opacity-50 z-30 flex items-center justify-center px-6">
          <div className="bg-white rounded-xl w-full p-4">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-bold text-lg">Edit Profile</h3>
              <button onClick={() => setShowEditModal(false)}>
                <X size={20} className="text-gray-500" />
              </button>
            </div>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Display Name</label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                  defaultValue="John Davis"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                  defaultValue="San Francisco, CA"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Bio</label>
                <textarea
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                  defaultValue="Tech enthusiast and coffee lover. Always up for a good tennis match or trying new restaurants. Looking to meet interesting people in the city."
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Interests</label>
                <div className="flex flex-wrap gap-2 mb-2">
                  {Object.keys(interestDetails).map(interest => (
                    <span key={interest} className="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs flex items-center">
                      {interest}
                      <X size={14} className="ml-1" />
                    </span>
                  ))}
                </div>
                <div className="relative">
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    placeholder="Add more interests..."
                  />
                  <button className="absolute right-2 top-1/2 transform -translate-y-1/2 text-blue-500 px-2 py-1 text-sm">
                    Add
                  </button>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Availability Status</label>
                <div className="space-y-2">
                  <div className="flex items-center">
                    <input type="radio" id="available" name="status" className="mr-3" checked />
                    <label htmlFor="available" className="flex items-center">
                      <div className="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
                      <span>Available now</span>
                    </label>
                  </div>
                  <div className="flex items-center">
                    <input type="radio" id="later" name="status" className="mr-3" />
                    <label htmlFor="later" className="flex items-center">
                      <div className="w-3 h-3 rounded-full bg-yellow-500 mr-2"></div>
                      <span>Available later</span>
                    </label>
                  </div>
                  <div className="flex items-center">
                    <input type="radio" id="unavailable" name="status" className="mr-3" />
                    <label htmlFor="unavailable" className="flex items-center">
                      <div className="w-3 h-3 rounded-full bg-gray-500 mr-2"></div>
                      <span>Not available</span>
                    </label>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="mt-6 flex space-x-2">
              <button 
                className="flex-1 bg-gray-200 py-2 rounded-lg font-medium"
                onClick={() => setShowEditModal(false)}
              >
                Cancel
              </button>
              <button 
                className="flex-1 bg-blue-500 text-white py-2 rounded-lg font-medium"
                onClick={() => setShowEditModal(false)}
              >
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Donation Management Modal */}
      {showDonationModal && (
        <div className="absolute inset-0 bg-black bg-opacity-50 z-30 flex items-center justify-center">
          <div className="bg-white rounded-xl w-full mx-4 p-4 max-h-[90%] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-bold text-xl">Donor Membership</h3>
              <button onClick={() => setShowDonationModal(false)} className="p-1">
                <X size={20} className="text-gray-500" />
              </button>
            </div>
            
            {/* Current Membership */}
            <div className="mb-5">
              <h4 className="font-bold text-sm text-gray-500 uppercase mb-2">Current Membership</h4>
              <div className="bg-green-50 rounded-xl p-4 border border-green-100">
                <div className="flex items-center mb-3">
                  <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mr-3">
                    <Heart size={24} className="text-green-600" />
                  </div>
                  <div className="flex-grow">
                    <h3 className="font-bold text-lg">Silver Donor</h3>
                    <p className="text-sm text-gray-600">$5/month • Renewed on 26th</p>
                  </div>
                  <div className="bg-green-500 text-white px-2 py-1 rounded-lg text-xs">
                    Active
                  </div>
                </div>
                
                <div className="pt-3 border-t border-green-200">
                  <button className="w-full bg-white border border-gray-300 py-2 rounded-lg font-medium text-sm">
                    Update Payment Method
                  </button>
                </div>
              </div>
            </div>
            
            {/* Current Benefits */}
            <div className="mb-5">
              <h4 className="font-bold text-sm text-gray-500 uppercase mb-2">Your Benefits</h4>
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <ul className="space-y-3">
                  <li className="flex items-start">
                    <div className="w-5 h-5 rounded-full bg-green-100 flex-shrink-0 flex items-center justify-center mr-2 mt-0.5">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="3">
                        <path d="M5 12l5 5L20 7" />
                      </svg>
                    </div>
                    <div>
                      <p className="text-sm font-medium">Donor Badge on Profile</p>
                      <p className="text-xs text-gray-500">Makes your profile stand out</p>
                    </div>
                  </li>
                  <li className="flex items-start">
                    <div className="w-5 h-5 rounded-full bg-green-100 flex-shrink-0 flex items-center justify-center mr-2 mt-0.5">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="3">
                        <path d="M5 12l5 5L20 7" />
                      </svg>
                    </div>
                    <div>
                      <p className="text-sm font-medium">+10% More Bond Tokens</p>
                      <p className="text-xs text-gray-500">Earn more tokens for each connection</p>
                    </div>
                  </li>
                  <li className="flex items-start">
                    <div className="w-5 h-5 rounded-full bg-green-100 flex-shrink-0 flex items-center justify-center mr-2 mt-0.5">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="3">
                        <path d="M5 12l5 5L20 7" />
                      </svg>
                    </div>
                    <div>
                      <p className="text-sm font-medium">Priority Match Suggestions</p>
                      <p className="text-xs text-gray-500">Get shown to more potential matches</p>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
            
            {/* Upgrades */}
            <div className="mb-5">
              <h4 className="font-bold text-sm text-gray-500 uppercase mb-2">Upgrade Options</h4>
              
              <div className="bg-white rounded-xl p-4 border-2 border-purple-300 mb-3">
                <div className="flex items-center mb-3">
                  <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center mr-3">
                    <Heart size={24} className="text-purple-600" />
                  </div>
                  <div className="flex-grow">
                    <div className="flex items-center">
                      <h3 className="font-bold text-lg">Gold Donor</h3>
                      <span className="ml-2 bg-purple-100 text-purple-700 text-xs px-2 py-0.5 rounded-full">Popular</span>
                    </div>
                    <p className="text-sm text-gray-600">$10/month</p>
                  </div>
                </div>
                
                <ul className="space-y-2 mb-4">
                  <li className="flex items-center text-sm">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="2" className="mr-2">
                      <path d="M5 12l5 5L20 7" />
                    </svg>
                    <span>All Silver benefits</span>
                  </li>
                  <li className="flex items-center text-sm">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="2" className="mr-2">
                      <path d="M5 12l5 5L20 7" />
                    </svg>
                    <span>Advanced compatibility insights</span>
                  </li>
                  <li className="flex items-center text-sm">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="2" className="mr-2">
                      <path d="M5 12l5 5L20 7" />
                    </svg>
                    <span>Ad-free experience</span>
                  </li>
                </ul>
                
                <button className="w-full bg-purple-600 text-white py-2.5 rounded-lg font-medium text-sm">
                  Upgrade to Gold
                </button>
              </div>
            </div>
            
            {/* Manage Subscription */}
            <div className="mt-5">
              <button className="w-full text-gray-500 py-2">
                Cancel Subscription
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Interest Detail Popup */}
      {selectedInterest && (
        <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-10">
          <div className="bg-white rounded-xl w-full max-w-xs p-4">
            <div className="flex justify-between items-center mb-3">
              <div className="flex items-center">
                <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center mr-3 text-xl">
                  {interestDetails[selectedInterest].icon}
                </div>
                <h3 className="font-bold text-lg">{selectedInterest}</h3>
              </div>
              <button 
                className="p-1 rounded-full hover:bg-gray-100"
                onClick={() => setSelectedInterest(null)}
              >
                <X size={20} className="text-gray-500" />
              </button>
            </div>
            
            <div className="space-y-3 mb-3">
              <div className="flex justify-between">
                <span className="text-gray-500">Experience:</span>
                <span className="font-medium">{interestDetails[selectedInterest].experience}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Level:</span>
                <span className="font-medium">{interestDetails[selectedInterest].level}</span>
              </div>
            </div>
            
            <p className="text-gray-700 text-sm border-t border-gray-100 pt-3">
              {interestDetails[selectedInterest].description}
            </p>
            
            <div className="flex space-x-2 mt-4">
              <button 
                className="flex-1 bg-gray-200 py-2 rounded-lg font-medium text-sm"
                onClick={() => setSelectedInterest(null)}
              >
                Cancel
              </button>
              <button 
                className="flex-1 bg-blue-500 text-white py-2 rounded-lg font-medium text-sm"
                onClick={() => setShowEditModal(true)}
              >
                Edit Interest
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default MyProfile;