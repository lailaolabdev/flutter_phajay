import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_phajay/src/payment_state.dart';

class CreditCardWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final Function() onPaymentSuccess;
  final Function(String error) onPaymentError;

  const CreditCardWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<CreditCardWebViewScreen> createState() =>
      _CreditCardWebViewScreenState();
}

class _CreditCardWebViewScreenState extends State<CreditCardWebViewScreen> {
  InAppWebViewController? _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void _injectViewportMeta() async {
    if (_controller != null) {
      await _controller!.evaluateJavascript(
        source: '''
        (function () {
          // Enhanced viewport configuration for mobile payment pages
          var old = document.querySelector('meta[name="viewport"]');
          if (old) old.remove();
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover, shrink-to-fit=no';
          document.head.appendChild(meta);

          // Enhanced mobile CSS for payment forms
          var style = document.createElement('style');
          style.innerHTML = `
            /* Prevent zoom on inputs */
            input, textarea, select {
              font-size: 16px !important;
              transform-origin: left top;
              zoom: 1 !important;
              -webkit-appearance: none;
              border-radius: 4px;
              touch-action: manipulation;
            }
            
            /* Ensure smooth scrolling */
            html, body {
              scroll-behavior: smooth;
              -webkit-overflow-scrolling: touch;
              touch-action: auto;
              overflow-x: hidden;
              overflow-y: auto;
              height: auto;
              min-height: 100vh;
            }
            
            /* Enhanced input focus styles */
            input:focus, textarea:focus, select:focus {
              outline: 2px solid #007AFF;
              outline-offset: 2px;
              scroll-margin-top: 100px;
              scroll-margin-bottom: 100px;
            }
            
            /* Form container optimization */
            form, .payment-form, .card-form {
              touch-action: auto;
              overflow: visible;
            }
            
            /* Ensure all containers allow scroll */
            * {
              box-sizing: border-box;
            }
            
            .container, .content, .main-content {
              touch-action: auto;
              overflow: visible;
            }
          `;
          document.head.appendChild(style);

          // Enhanced input focus handling with keyboard awareness
          var currentInput = null;
          var isKeyboardVisible = false;
          var keyboardHeight = 0;
          var keyboardSpacer = null;
          
          // Function to create/update keyboard spacer
          function updateKeyboardSpacer(height) {
            console.log('🔧 Updating keyboard spacer with height:', height);
            
            // Remove existing spacers
            var existingSpacers = document.querySelectorAll('#keyboard-spacer, .keyboard-spacer');
            existingSpacers.forEach(function(spacer) {
              spacer.remove();
            });
            keyboardSpacer = null;
            
            // Create new spacer if keyboard is visible
            if (height > 50) {
              keyboardSpacer = document.createElement('div');
              keyboardSpacer.id = 'keyboard-spacer';
              keyboardSpacer.className = 'keyboard-spacer';
              
              // Make spacer larger to ensure full scroll capability
              // var spacerHeight = height + 200; // เพิ่ม buffer มากขึ้น
              var spacerHeight = height; // เพิ่ม buffer มากขึ้น
              keyboardSpacer.style.height = spacerHeight + 'px';
              keyboardSpacer.style.width = '100%';
              keyboardSpacer.style.visibility = 'hidden';
              keyboardSpacer.style.pointerEvents = 'none';
              keyboardSpacer.style.backgroundColor = 'transparent';
              keyboardSpacer.style.display = 'block';
              keyboardSpacer.style.position = 'relative';
              keyboardSpacer.style.zIndex = '-1';
              
              // Append to body
              document.body.appendChild(keyboardSpacer);
              
              // Force body to recognize new height
              document.body.style.minHeight = 'auto';
              document.body.style.height = 'auto';
              
              // Force recalculate document height
              setTimeout(function() {
                var totalHeight = document.body.scrollHeight;
                console.log('📏 Keyboard spacer added:', spacerHeight, 'px. Total document height:', totalHeight);
                
                // Test scroll to ensure it works
                var maxScrollTop = totalHeight - window.innerHeight;
                console.log('📊 Max scroll possible:', maxScrollTop);
              }, 100);
              
            } else {
              console.log('🗑️ Keyboard spacer removed - keyboard hidden');
              
              // Reset body height when keyboard closes
              document.body.style.minHeight = '100vh';
            }
          }
          
          // Track viewport changes for keyboard detection
          if (window.visualViewport) {
            window.visualViewport.addEventListener('resize', function() {
              var previousKeyboardHeight = keyboardHeight;
              keyboardHeight = window.innerHeight - window.visualViewport.height;
              var wasKeyboardVisible = isKeyboardVisible;
              isKeyboardVisible = keyboardHeight > 50;
              
              console.log('📱 Viewport resize - Keyboard:', isKeyboardVisible ? 'visible' : 'hidden', 'Height:', keyboardHeight, 'Previous:', previousKeyboardHeight);
              
              // Update spacer when keyboard state changes
              if (keyboardHeight !== previousKeyboardHeight) {
                console.log('🔄 Keyboard height changed, updating spacer...');
                updateKeyboardSpacer(keyboardHeight);
                
                // Additional test after spacer update
                setTimeout(function() {
                  var docHeight = document.body.scrollHeight;
                  var winHeight = window.innerHeight;
                  var maxScroll = docHeight - winHeight;
                  
                  console.log('📊 After spacer update - Doc:', docHeight, 'Win:', winHeight, 'Max scroll:', maxScroll);
                  
                  // If we can't scroll much, add more spacer
                  if (isKeyboardVisible && maxScroll < keyboardHeight) {
                    console.log('⚠️ Insufficient scroll capability, adding extra spacer');
                    updateKeyboardSpacer(keyboardHeight + 300);
                  }
                }, 200);
              }
              
              // If switching from no keyboard to keyboard, ensure current input stays visible
              if (!wasKeyboardVisible && isKeyboardVisible && currentInput) {
                setTimeout(function() {
                  if (currentInput) {
                    try {
                      currentInput.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center',
                        inline: 'nearest'
                      });
                      console.log('🔄 Re-scrolled to current input after keyboard appeared');
                    } catch(e) {
                      console.log('Re-scroll failed:', e);
                    }
                  }
                }, 250);
              }
            });
          }

          // Enhanced focus handling
          document.addEventListener('focusin', function(e) {
            var target = e.target;
            if (target && (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.tagName === 'SELECT')) {
              var previousInput = currentInput;
              currentInput = target;
              var isFieldChange = previousInput && previousInput !== target;
              
              console.log('📝 Input focused:', target.type || target.tagName, 'Field change:', isFieldChange, 'Keyboard visible:', isKeyboardVisible);
              
              // If keyboard is already visible and we're changing fields, ensure full scroll capability
              if (isKeyboardVisible && isFieldChange) {
                console.log('🔄 Field change with keyboard visible - ensuring full scroll');
                
                // Immediately force scroll capability
                document.body.style.overflow = 'auto';
                document.body.style.overflowY = 'auto';
                document.body.style.height = 'auto';
                document.body.style.maxHeight = 'none';
                document.documentElement.style.overflow = 'auto';
                document.documentElement.style.overflowY = 'auto';
                
                // Force update spacer and test scroll capability
                setTimeout(function() {
                  console.log('🔧 Forcing spacer update for field change...');
                  updateKeyboardSpacer(keyboardHeight);
                  
                  // Test scroll capability after spacer update
                  setTimeout(function() {
                    var documentHeight = Math.max(
                      document.body.scrollHeight,
                      document.body.offsetHeight,
                      document.documentElement.scrollHeight,
                      document.documentElement.offsetHeight
                    );
                    var maxScroll = documentHeight - window.innerHeight;
                    var currentScroll = window.pageYOffset;
                    
                    console.log('🧪 Scroll test - Doc height:', documentHeight, 'Window height:', window.innerHeight, 'Max scroll:', maxScroll, 'Current:', currentScroll);
                    
                    // Test if we can scroll to bottom
                    var testScrollTarget = Math.max(0, maxScroll - 100);
                    if (testScrollTarget > currentScroll) {
                      console.log('✅ Scroll capability confirmed - can scroll to:', testScrollTarget);
                    } else {
                      console.log('⚠️ May need larger spacer');
                      // Add extra spacer if needed
                      updateKeyboardSpacer(keyboardHeight + 100);
                    }
                  }, 150);
                }, 25);
              }
              
              // Multiple scroll methods for better compatibility
              setTimeout(function() {
                if (currentInput) {
                  // Method 1: ScrollIntoView
                  try {
                    currentInput.scrollIntoView({
                      behavior: 'smooth', 
                      block: 'center',
                      inline: 'nearest'
                    });
                    console.log('✅ ScrollIntoView applied');
                  } catch(e) {
                    console.log('⚠️ ScrollIntoView failed:', e);
                  }
                  
                  // Method 2: Enhanced manual scroll calculation
                  setTimeout(function() {
                    if (currentInput) {
                      try {
                        var rect = currentInput.getBoundingClientRect();
                        var viewportHeight = window.visualViewport ? window.visualViewport.height : window.innerHeight;
                        var scrollTop = window.pageYOffset;
                        
                        // Calculate if field is hidden behind keyboard
                        var fieldBottom = rect.bottom;
                        var fieldTop = rect.top;
                        var availableHeight = viewportHeight - 50; // 50px buffer
                        
                        console.log('📊 Scroll calculation - Field top:', fieldTop, 'Field bottom:', fieldBottom, 'Available height:', availableHeight);
                        
                        if (fieldBottom > availableHeight) {
                          // Field is below visible area, scroll down
                          var scrollOffset = fieldBottom - availableHeight + 80;
                          window.scrollBy({
                            top: scrollOffset,
                            behavior: 'smooth'
                          });
                          console.log('📍 Scrolled down by:', scrollOffset);
                        } else if (fieldTop < 100) {
                          // Field is too high, scroll up a bit
                          var scrollUpOffset = 100 - fieldTop;
                          window.scrollBy({
                            top: -scrollUpOffset,
                            behavior: 'smooth'
                          });
                          console.log('📍 Scrolled up by:', scrollUpOffset);
                        }
                        
                        // Additional check: if this is a field change and keyboard is visible,
                        // ensure we can access the full document
                        if (isFieldChange && isKeyboardVisible) {
                          setTimeout(function() {
                            // Test scroll to ensure full document is accessible
                            var documentHeight = Math.max(
                              document.body.scrollHeight,
                              document.body.offsetHeight,
                              document.documentElement.clientHeight,
                              document.documentElement.scrollHeight,
                              document.documentElement.offsetHeight
                            );
                            
                            // Ensure spacer is adequate for full scroll
                            var neededSpacer = keyboardHeight + 150;
                            if (keyboardSpacer) {
                              var currentSpacerHeight = parseInt(keyboardSpacer.style.height);
                              if (currentSpacerHeight < neededSpacer) {
                                keyboardSpacer.style.height = neededSpacer + 'px';
                                console.log('📏 Updated spacer height to:', neededSpacer);
                              }
                            }
                            
                            console.log('📏 Document height:', documentHeight, 'Viewport height:', viewportHeight, 'Keyboard height:', keyboardHeight);
                          }, 100);
                        }
                        
                      } catch(e) {
                        console.log('⚠️ Manual scroll failed:', e);
                      }
                    }
                  }, isFieldChange && isKeyboardVisible ? 100 : 300);
                }
              }, isFieldChange ? 100 : 200);
            }
          }, true);

          // Handle focus out
          document.addEventListener('focusout', function(e) {
            if (currentInput === e.target) {
              setTimeout(function() {
                currentInput = null;
              }, 200);
            }
          }, true);

          // Handle touch events for smooth scrolling
          var touchStartY = 0;
          var isScrolling = false;
          var lastScrollTime = 0;
          
          document.addEventListener('touchstart', function(e) {
            if (e.touches.length === 1) {
              touchStartY = e.touches[0].clientY;
              isScrolling = false;
              lastScrollTime = Date.now();
              
              // If keyboard is visible, ensure scrolling is enabled
              if (isKeyboardVisible) {
                document.body.style.overflow = 'auto';
                document.body.style.overflowY = 'auto';
                document.body.style.touchAction = 'auto';
                console.log('🔓 Touch scroll enabled for keyboard context');
              }
            } else if (e.touches.length >= 2) {
              // Prevent pinch zoom
              e.preventDefault();
            }
          }, {passive: false});
          
          document.addEventListener('touchmove', function(e) {
            if (e.touches.length === 1) {
              var touchY = e.touches[0].clientY;
              var deltaY = Math.abs(touchY - touchStartY);
              if (deltaY > 5) {
                isScrolling = true;
                
                // During keyboard context, ensure continuous scroll capability
                if (isKeyboardVisible) {
                  document.body.style.overflow = 'auto';
                  document.body.style.overflowY = 'auto';
                  document.documentElement.style.overflow = 'auto';
                  document.documentElement.style.overflowY = 'auto';
                  
                  // Update spacer in real-time if needed
                  var now = Date.now();
                  if (now - lastScrollTime > 100) { // Throttle updates
                    updateKeyboardSpacer(keyboardHeight);
                    lastScrollTime = now;
                  }
                }
              }
            } else if (e.touches.length >= 2) {
              // Prevent pinch zoom
              e.preventDefault();
            }
          }, {passive: false});
          
          // Enhanced click handling for input fields during keyboard context
          document.addEventListener('click', function(e) {
            var target = e.target;
            if (target && (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.tagName === 'SELECT')) {
              console.log('👆 Input clicked:', target.type || target.tagName, 'Keyboard visible:', isKeyboardVisible);
              
              // If keyboard is already visible, this is likely a field change
              if (isKeyboardVisible && target !== currentInput) {
                console.log('🔄 Field switch with keyboard visible');
                
                // Immediately ensure full scroll capability
                setTimeout(function() {
                  // Force enable scrolling
                  document.body.style.overflow = 'auto';
                  document.body.style.overflowY = 'auto';
                  document.body.style.height = 'auto';
                  document.body.style.maxHeight = 'none';
                  document.documentElement.style.overflow = 'auto';
                  document.documentElement.style.overflowY = 'auto';
                  
                  // Ensure spacer is adequate
                  updateKeyboardSpacer(keyboardHeight);
                  
                  // Calculate and apply scroll if needed
                  if (target) {
                    try {
                      var rect = target.getBoundingClientRect();
                      var viewportHeight = window.visualViewport ? window.visualViewport.height : window.innerHeight;
                      
                      // Check if field needs scrolling
                      if (rect.bottom > viewportHeight - 50) {
                        var scrollAmount = rect.bottom - viewportHeight + 100;
                        window.scrollBy({
                          top: scrollAmount,
                          behavior: 'smooth'
                        });
                        console.log('📍 Click scroll applied:', scrollAmount);
                      }
                    } catch(e) {
                      console.log('⚠️ Click scroll failed:', e);
                    }
                  }
                }, 50);
              }
            }
          }, true);
          
          // Prevent double-tap zoom (except on form elements)
          var lastTap = 0;
          document.addEventListener('touchend', function(e) {
            var now = Date.now();
            var timeDiff = now - lastTap;
            
            if (timeDiff < 300 && timeDiff > 0 && !isScrolling) {
              var target = e.target;
              if (target.tagName !== 'INPUT' && target.tagName !== 'TEXTAREA' && 
                  target.tagName !== 'SELECT' && target.tagName !== 'BUTTON') {
                e.preventDefault();
                console.log('🚫 Double-tap zoom prevented');
              }
            }
            
            lastTap = now;
            isScrolling = false;
          }, {passive: false});

          console.log('🚀 InAppWebView enhanced mobile optimization injected');
        })();
      ''',
      );
    }
  }

  void _handleUrlChange(String url) {
    print('🔍 Checking URL: $url');

    // Check for success patterns in URL
    if (_isSuccessUrl(url)) {
      if (!PaymentState().isPaymentCompleted) {
        print('🎉 Credit card payment successful');
        PaymentState().markPaymentCompleted();

        // Pop this screen and call success callback
        Navigator.of(context).pop();
        widget.onPaymentSuccess();
      }
    }
    // Check for failure patterns in URL
    else if (_isFailureUrl(url)) {
      Navigator.of(context).pop();
      widget.onPaymentError('Credit card payment failed');
    }
    // Check for cancel patterns in URL
    else if (_isCancelUrl(url)) {
      Navigator.of(context).pop();
      widget.onPaymentError('Credit card payment cancelled');
    }
  }

  bool _isSuccessUrl(String url) {
    // Common success URL patterns
    final successPatterns = [
      'success',
      'approved',
      'completed',
      'payment_success',
      'transaction_success',
      'status=success',
      'status=approved',
      'status=completed',
    ];

    final lowerUrl = url.toLowerCase();
    return successPatterns.any((pattern) => lowerUrl.contains(pattern));
  }

  bool _isFailureUrl(String url) {
    // Common failure URL patterns
    final failurePatterns = [
      'failed',
      'error',
      'declined',
      'payment_failed',
      'transaction_failed',
      'status=failed',
      'status=error',
      'status=declined',
    ];

    final lowerUrl = url.toLowerCase();
    return failurePatterns.any((pattern) => lowerUrl.contains(pattern));
  }

  bool _isCancelUrl(String url) {
    // Common cancel URL patterns
    final cancelPatterns = [
      'cancel',
      'cancelled',
      'payment_cancel',
      'transaction_cancel',
      'status=cancel',
      'status=cancelled',
    ];

    final lowerUrl = url.toLowerCase();
    return cancelPatterns.any((pattern) => lowerUrl.contains(pattern));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // ให้ JavaScript จัดการ keyboard เอง!
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Credit Card Payment',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator
          if (isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          // InAppWebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                // Mobile optimization settings
                useOnDownloadStart: false,
                useOnLoadResource: false,
                useShouldOverrideUrlLoading: false,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllowFullscreen: true,
                // Scroll and zoom settings
                supportZoom: false,
                disableDefaultErrorPage: true,
                // iOS specific settings
                allowsLinkPreview: false,
                allowsBackForwardNavigationGestures: true,
                // Android specific settings
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                textZoom: 100,
                forceDark: ForceDark.OFF,
                // Performance settings
                cacheEnabled: true,
                clearCache: false,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                print('🌐 InAppWebView created');
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
                print('🌐 Page started loading: $url');
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
                print('🌐 Page finished loading: $url');
                if (url != null) {
                  _handleUrlChange(url.toString());
                }
                _injectViewportMeta();
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();
                print('🌐 Navigation request: $url');
                _handleUrlChange(url);
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                print('❌ WebView error: ${error.description}');
                widget.onPaymentError('WebView error: ${error.description}');
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('📝 Console: ${consoleMessage.message}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
