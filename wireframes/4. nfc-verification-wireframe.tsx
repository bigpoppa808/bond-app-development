import React, { useState } from 'react';
import { ChevronLeft, X, Phone, Zap, Check } from 'lucide-react';

const NFCVerificationWireframe = () => {
  // Simulate the verification process
  const [verificationStep, setVerificationStep] = useState('initial'); // initial, scanning, success
  
  // For demo purposes, automatically progress through verification steps
  React.useEffect(() => {
    if (verificationStep === 'scanning') {
      const timer = setTimeout(() => {
        setVerificationStep('success');
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [verificationStep]);
  
  return (
    <div className="w-full max-w-md mx-auto bg-gray-50" style={{ height: '640px', width: '360px', position: 'relative' }}>
      {/* Status Bar */}
      <div className="bg-gray-50 text-black p-4 text-base flex justify-between items-center">
        <span className="font-medium">9:41 AM</span>
      </div>
      
      {/* Header */}
      <div className="px-4 py-2 flex items-center justify-between">
        <button>
          <ChevronLeft size={24} color="#374151" />
        </button>
        <h1 className="text-xl font-bold">Verify Connection</h1>
        <button>
          <X size={24} color="#374151" />
        </button>
      </div>
      
      {/* Content Area */}
      <div className="h-full pt-6 pb-16 px-4">
        {verificationStep === 'initial' && (
          <div className="flex flex-col items-center justify-center h-4/5">
            {/* User Connection Info */}
            <div className="flex items-center justify-center space-x-4 mb-8">
              <div className="relative">
                <div className="w-20 h-20 bg-gray-300 rounded-full"></div>
                <div className="absolute bottom-0 right-0 w-6 h-6 bg-green-500 rounded-full border-2 border-white"></div>
              </div>
              
              <div className="w-10 flex items-center justify-center">
                <div className="w-8 h-1 bg-blue-500 rounded-full"></div>
              </div>
              
              <div className="relative">
                <div className="w-20 h-20 bg-gray-300 rounded-full"></div>
                <div className="absolute bottom-0 right-0 w-6 h-6 bg-green-500 rounded-full border-2 border-white"></div>
              </div>
            </div>
            
            <h2 className="text-2xl font-bold text-center mb-2">Connect with Sarah</h2>
            <p className="text-gray-600 text-center mb-8">Tap phones together to verify your in-person connection</p>
            
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-8 w-full max-w-xs">
              <div className="flex items-start">
                <Zap size={20} className="text-blue-500 mr-2 mt-0.5" />
                <div>
                  <h3 className="font-bold text-blue-800">Earn 100 Bond Tokens</h3>
                  <p className="text-blue-600 text-sm">Verify your connection with NFC to earn tokens!</p>
                </div>
              </div>
            </div>
            
            <button 
              className="bg-blue-500 text-white py-3 px-8 rounded-full font-medium text-lg shadow-md"
              onClick={() => setVerificationStep('scanning')}
            >
              Start Verification
            </button>
          </div>
        )}
        
        {verificationStep === 'scanning' && (
          <div className="flex flex-col items-center justify-center h-4/5">
            <div className="relative mb-8">
              <div className="w-36 h-36 rounded-full bg-blue-100 flex items-center justify-center">
                <div className="w-24 h-24 rounded-full bg-blue-300 flex items-center justify-center animate-pulse">
                  <Phone size={48} className="text-blue-600" />
                </div>
              </div>
              <div className="absolute inset-0 border-4 border-blue-500 rounded-full animate-ping opacity-30"></div>
            </div>
            
            <h2 className="text-2xl font-bold text-center mb-2">Scanning...</h2>
            <p className="text-gray-600 text-center mb-8">Keep your phones together until verification completes</p>
            
            <div className="bg-gray-200 rounded-full w-48 h-2 mb-2">
              <div className="bg-blue-500 rounded-full h-2 w-2/3 animate-pulse"></div>
            </div>
            <p className="text-gray-500 text-sm">Verifying connection...</p>
          </div>
        )}
        
        {verificationStep === 'success' && (
          <div className="flex flex-col items-center justify-center h-4/5">
            <div className="relative mb-8">
              <div className="w-36 h-36 rounded-full bg-green-100 flex items-center justify-center">
                <div className="w-24 h-24 rounded-full bg-green-500 flex items-center justify-center">
                  <Check size={48} className="text-white" />
                </div>
              </div>
            </div>
            
            <h2 className="text-2xl font-bold text-center mb-2">Connection Verified!</h2>
            <p className="text-gray-600 text-center mb-8">You've successfully connected with Sarah</p>
            
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-8 w-full max-w-xs">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-bold text-blue-800">Bond Tokens Earned</h3>
                  <p className="text-blue-600 text-sm">First connection bonus!</p>
                </div>
                <div className="bg-blue-500 text-white font-bold px-3 py-1 rounded-lg">
                  +100
                </div>
              </div>
            </div>
            
            <button className="bg-blue-500 text-white py-3 px-8 rounded-full font-medium text-lg shadow-md mb-3">
              Send a Message
            </button>
            
            <button className="text-blue-500 font-medium">
              Return to Home
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default NFCVerificationWireframe;
