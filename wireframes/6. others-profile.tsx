import React, { useState } from 'react';
import { ChevronLeft, MapPin, Calendar, Star, MessageCircle, Map, Heart, Users, Award, UserPlus, ChevronDown, X, Zap } from 'lucide-react';

const OtherUserProfile = () => {
  const [expandedCompatibility, setExpandedCompatibility] = useState(false);
  const [selectedInterest, setSelectedInterest] = useState(null);
  
  // Interest details data
  const interestDetails = {
    "Basketball": {
      icon: "🏀",
      experience: "5+ years",
      level: "Intermediate",
      description: "Plays pickup games regularly. Likes both casual games and watching NBA."
    },
    "Craft Beer": {
      icon: "🍺",
      experience: "3 years",
      level: "Enthusiast",
      description: "Enjoys trying local breweries and has visited over 25 different ones in the area."
    },
    "Technology": {
      icon: "💻",
      experience: "10+ years",
      level: "Professional",
      description: "Works in tech marketing and stays up-to-date with the latest gadgets and trends."
    },
    "Food": {
      icon: "🍽️",
      experience: "Lifelong passion",
      level: "Foodie",
      description: "Loves exploring new restaurants and trying different cuisines. Particularly enjoys Asian fusion."
    },
    "Photography": {
      icon: "📷",
      experience: "2 years",
      level: "Hobbyist",
      description: "Recently picked up street photography and urban landscapes. Uses a Sony mirrorless camera."
    }
  };
  
  return (
    <div style={{ height: '640px', width: '360px', position: 'relative' }} className="bg-gray-50">
      {/* Header */}
      <div className="px-4 py-4 flex items-center">
        <button className="mr-2">
          <ChevronLeft size={24} color="#374151" />
        </button>
        <h1 className="text-xl font-bold">Profile</h1>
      </div>
      
      {/* Profile Info */}
      <div className="px-4 mb-4">
        <div className="flex items-start">
          <div className="relative mr-4">
            <div className="w-20 h-20 bg-gray-300 rounded-full"></div>
            <div className="absolute bottom-0 right-0 w-6 h-6 bg-green-500 rounded-full border-2 border-white"></div>
          </div>
          <div>
            <h2 className="text-xl font-bold">Alex Johnson</h2>
            
            <div className="flex items-center mt-1 mb-1">
              <Zap size={14} className="text-blue-500 mr-1" />
              <span className="text-blue-500 font-medium text-sm">720 Bond Tokens</span>
            </div>
            
            <div className="text-gray-600 text-sm mb-1">
              <MapPin size={14} className="inline mr-1" />
              <span>San Francisco • 0.5 miles away</span>
            </div>
            
            <div className="flex">
              <div className="px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded-full flex items-center">
                <div className="w-2 h-2 rounded-full bg-green-500 mr-1"></div>
                <span>Available now</span>
              </div>
              <div className="ml-2 px-2 py-0.5 bg-purple-100 text-purple-700 text-xs rounded-full flex items-center">
                <Heart size={10} className="mr-1" />
                <span>Gold Donor</span>
              </div>
            </div>
          </div>
        </div>
        
        {/* Action Buttons - Rearranged */}
        <div className="flex space-x-2 mt-3">
          <button className="flex-1 bg-blue-500 text-white py-1.5 rounded-lg font-medium flex items-center justify-center">
            <UserPlus size={16} className="mr-1" />
            <span>Connect</span>
          </button>
          <button className="flex-1 bg-white border border-gray-200 shadow-sm text-gray-700 py-1.5 rounded-lg font-medium flex items-center justify-center">
            <MessageCircle size={16} className="mr-1 text-blue-500" />
            <span>Message</span>
          </button>
        </div>
      </div>
      
      {/* Compatibility Score - More Detailed */}
      <div 
        className="bg-white rounded-xl mx-4 mb-4 shadow-sm overflow-hidden"
        onClick={() => setExpandedCompatibility(!expandedCompatibility)}
      >
        <div className="p-3">
          <div className="flex items-center justify-between">
            <h3 className="font-bold">Compatibility Score</h3>
            <div className="flex items-center">
              <div className="flex">
                <Star size={16} fill="#FBBF24" stroke="#FBBF24" className="text-yellow-400" />
                <Star size={16} fill="#FBBF24" stroke="#FBBF24" className="text-yellow-400" />
                <Star size={16} fill="#FBBF24" stroke="#FBBF24" className="text-yellow-400" />
                <Star size={16} fill="#FBBF24" stroke="#FBBF24" className="text-yellow-400" />
                <Star size={16} fill="none" stroke="#FBBF24" className="text-yellow-400" />
              </div>
              <span className="ml-2 font-bold text-blue-500">82%</span>
            </div>
          </div>
        </div>
        
        <div className="px-3 pb-2 pt-0 flex items-center justify-between text-sm text-gray-500">
          <span>Tap to see details</span>
          <ChevronDown size={16} className={`transition-transform ${expandedCompatibility ? 'rotate-180' : ''}`} />
        </div>
        
        {expandedCompatibility && (
          <div className="bg-gray-50 px-3 py-3 border-t border-gray-200">
            <div className="space-y-4">
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600">Interests Match</span>
                  <div className="flex items-center">
                    <span className="font-medium text-green-600">Excellent</span>
                    <span className="ml-2 font-medium">85%</span>
                  </div>
                </div>
                <div className="h-2 bg-gray-200 rounded-full">
                  <div className="h-2 bg-green-500 rounded-full" style={{ width: '85%' }}></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">You share 5 interests including Technology and Food</p>
              </div>
              
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600">Availability Match</span>
                  <div className="flex items-center">
                    <span className="font-medium text-green-600">Great</span>
                    <span className="ml-2 font-medium">90%</span>
                  </div>
                </div>
                <div className="h-2 bg-gray-200 rounded-full">
                  <div className="h-2 bg-green-500 rounded-full" style={{ width: '90%' }}></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">Your schedules align on weekdays and weekends</p>
              </div>
              
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600">Location Convenience</span>
                  <div className="flex items-center">
                    <span className="font-medium text-yellow-600">Good</span>
                    <span className="ml-2 font-medium">70%</span>
                  </div>
                </div>
                <div className="h-2 bg-gray-200 rounded-full">
                  <div className="h-2 bg-yellow-500 rounded-full" style={{ width: '70%' }}></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">0.5 miles away • 10 minute walk</p>
              </div>
              
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600">Activity Preferences</span>
                  <div className="flex items-center">
                    <span className="font-medium text-green-600">Excellent</span>
                    <span className="ml-2 font-medium">85%</span>
                  </div>
                </div>
                <div className="h-2 bg-gray-200 rounded-full">
                  <div className="h-2 bg-green-500 rounded-full" style={{ width: '85%' }}></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">You both enjoy casual meet-ups and food exploration</p>
              </div>
            </div>
          </div>
        )}
      </div>
      
      {/* About */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <h3 className="font-bold text-sm mb-1">About</h3>
        <p className="text-gray-700 text-sm mb-2">
          Marketing specialist with a passion for basketball and craft beer. Recently moved to the city and looking to expand my social circle. Always down for a pickup game or checking out new breweries!
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
      
      {/* Common Interests */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <h3 className="font-bold text-sm mb-2">Common Interests</h3>
        <div className="space-y-1.5">
          <button 
            className="w-full flex items-center p-2 bg-blue-50 rounded-lg"
            onClick={() => setSelectedInterest("Technology")}
          >
            <div className="w-6 h-6 bg-blue-100 rounded-lg flex items-center justify-center mr-2">
              <span className="text-blue-600 text-xs">💻</span>
            </div>
            <span className="text-blue-700 font-medium text-sm">Technology</span>
          </button>
          
          <button 
            className="w-full flex items-center p-2 bg-blue-50 rounded-lg"
            onClick={() => setSelectedInterest("Food")}
          >
            <div className="w-6 h-6 bg-blue-100 rounded-lg flex items-center justify-center mr-2">
              <span className="text-blue-600 text-xs">🍽️</span>
            </div>
            <span className="text-blue-700 font-medium text-sm">Food</span>
          </button>
        </div>
      </div>
      
      {/* Availability & Meet-up */}
      <div className="bg-white rounded-xl mx-4 mb-4 p-3 shadow-sm">
        <h3 className="font-bold text-sm mb-2">Availability</h3>
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Today</span>
            </div>
            <span className="text-gray-600 text-sm">3:00 PM - 6:00 PM</span>
          </div>
          
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Wednesday</span>
            </div>
            <span className="text-gray-600 text-sm">5:00 PM - 8:00 PM</span>
          </div>
          
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-gray-100 rounded-lg flex items-center justify-center mr-2">
                <Calendar size={14} className="text-gray-600" />
              </div>
              <span className="font-medium text-sm">Sunday</span>
            </div>
            <span className="text-gray-600 text-sm">12:00 PM - 4:00 PM</span>
          </div>
        </div>
        
        <div className="flex space-x-2 mt-3">
          <button className="flex-1 bg-blue-100 text-blue-700 py-1.5 rounded-lg font-medium text-sm flex items-center justify-center">
            <Calendar size={16} className="mr-1" />
            <span>Schedule</span>
          </button>
          <button className="flex-1 bg-white border border-gray-200 shadow-sm text-gray-700 py-1.5 rounded-lg font-medium text-sm flex items-center justify-center">
            <Map size={16} className="mr-1 text-blue-500" />
            <span>Directions</span>
          </button>
        </div>
      </div>
      
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
            
            <button 
              className="w-full bg-blue-500 text-white py-2 rounded-lg font-medium mt-4 text-sm"
              onClick={() => setSelectedInterest(null)}
            >
              Got it
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default OtherUserProfile;