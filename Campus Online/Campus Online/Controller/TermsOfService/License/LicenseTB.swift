//
//  LicenseTB.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let id = "id"
class LicenseTB: UITableViewController {
    
    
    
    var lisansDisp : [String] = []
    var datSource : [String] = ["Lottie","RevealingSplashView","TweeTextField","Firebase","Firebase/Auth","Firebase/Firestore","Firebase/Storage"
        ,"Firebase/Analytics","Firebase/Messaging","Firebase/Crashlytics","SDWebImage","JJFloatingActionButton","JDropDownAlert","SVProgressHUD","PopupDialog","SwiftyAttributes","JSQMessagesViewController","ActiveLabel"]
    
    let Lottie = """
    <html>
       <head>
    <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width'>
    
      <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
       </head>
       <body>
       
       <br></br>
    <strong>Lottie</strong></br></br>


          <li>
              <a href="https://github.com/airbnb/lottie-ios"><b>Copyright 2018 Airbnb, Inc</b></a>
          </li>


     </br>
     
    <p>
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:</p></br>

    <p> The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.</p></br>

    <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.</p></br>
       </body>
       </html>
    """
    
    let RevealingSplashView = """
           <html>
           <head>
           <meta charset='utf-8'>
           <meta name='viewport' content='width=device-width'>

           <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
           </head>
           <body>
           
           <br></br>
           <strong>RevealingSplashView</strong></br></br>


           <li>
             <a href="https://github.com/PiXeL16/RevealingSplashView"><b>PiXeL16/RevealingSplashView</b></a>
           </li>


           </br>
           
           <p>
           The MIT License (MIT)</br></p>

           <p>  Copyright (c) 2016 Chris Jimenez</br>

           <p> Permission is hereby granted, free of charge, to any person obtaining a copy
           of this software and associated documentation files (the "Software"), to deal
           in the Software without restriction, including without limitation the rights
           to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
           copies of the Software, and to permit persons to whom the Software is
           furnished to do so, subject to the following conditions:</p></br>

           <p>The above copyright notice and this permission notice shall be included in all
           copies or substantial portions of the Software.</p></br>

           <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
           IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
           FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
           AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
           LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
           OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
           SOFTWARE.</p></br>
           </body>
           </html>
           """
    
    let TweeTextField = """
       
       <html>
           <head>
           <meta charset='utf-8'>
           <meta name='viewport' content='width=device-width'>

           <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
           </head>
           <body>
           
           <br></br>
           <strong>TweeTextField</strong></br></br>


           <li>
             <a href="https://github.com/PiXeL16/RevealingSplashView"><b>oleghnidets/TweeTextField</b></a>
           </li>


           </br>
           
           <p>
           The MIT License (MIT)</br></p>

           <p>  Copyright (c) 2017-2020 Oleg Hnidets </br>

           <p> Permission is hereby granted, free of charge, to any person obtaining a copy
           of this software and associated documentation files (the "Software"), to deal
           in the Software without restriction, including without limitation the rights
           to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
           copies of the Software, and to permit persons to whom the Software is
           furnished to do so, subject to the following conditions:</p></br>

           <p>The above copyright notice and this permission notice shall be included in all
           copies or substantial portions of the Software.</p></br>

           <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
           IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
           FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
           AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
           LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
           OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
           SOFTWARE.</p></br>
           </body>
           </html>
       
       """
    
    let firebaselis = """
               
           <html>
           <head>
           <meta charset='utf-8'>
           <meta name='viewport' content='width=device-width'>

           <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
           </head>
           <body>
           
           <br>
           <strong>Firebase</strong></br></br>


           <li>
           <a href="https://github.com/firebase/"><b>Firebase</b></a></br>
           </li>
           <p>  Google Inc </p>
           <p>Licensed under the Apache License, Version 2.0 (the "License");
           You may not use this file except in compliance with the License.
           You may obtain a copy of the License at</p></br>

           <li>
             <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
           </li></br>

           <p> Unless required by applicable law or agreed to in writing, software
           distributed under the License is distributed on an "AS IS" BASIS,
           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
           See the License for the specific language governing permissions and
           limitations under the License.</p></br>
           </body>
           </html>

           """
    
    
    
    let firebaselis_auth = """
                  
              <html>
              <head>
              <meta charset='utf-8'>
              <meta name='viewport' content='width=device-width'>

              <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
              </head>
              <body>
              
              <br>
              <strong>Firebase</strong></br></br>


              <li>
              <a href="https://github.com/firebase/firebase-ios-sdk/tree/master/FirebaseAuth"><b>Firebase/Auth</b></a></br>
              </li>
              <p>  Google Inc </p>
              <p>Licensed under the Apache License, Version 2.0 (the "License");
              You may not use this file except in compliance with the License.
              You may obtain a copy of the License at</p></br>

              <li>
                <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
              </li></br>

              <p> Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.</p></br>
              </body>
              </html>

              """
    
    let firebaselis_firestore = """
                  
              <html>
              <head>
              <meta charset='utf-8'>
              <meta name='viewport' content='width=device-width'>

              <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
              </head>
              <body>
              
              <br>
              <strong>Firebase</strong></br></br>


              <li>
              <a href="https://github.com/firebase/firebase-ios-sdk/tree/master/Firestore"><b>Firebase/Firestore</b></a></br>
              </li>
              <p>  Google Inc </p>
              <p>Licensed under the Apache License, Version 2.0 (the "License");
              You may not use this file except in compliance with the License.
              You may obtain a copy of the License at</p></br>

              <li>
                <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
              </li></br>

              <p> Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.</p></br>
              </body>
              </html>

              """
    
    
    let firebaselis_storage = """
                  
              <html>
              <head>
              <meta charset='utf-8'>
              <meta name='viewport' content='width=device-width'>

              <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
              </head>
              <body>
              
              <br>
              <strong>Firebase</strong></br></br>


              <li>
              <a href="https://github.com/firebase/firebase-ios-sdk/tree/master/FirebaseStorage"><b>Firebase/FirebaseStorage</b></a></br>
              </li>
              <p>  Google Inc </p>
              <p>Licensed under the Apache License, Version 2.0 (the "License");
              You may not use this file except in compliance with the License.
              You may obtain a copy of the License at</p></br>

              <li>
                <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
              </li></br>

              <p> Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.</p></br>
              </body>
              </html>

              """
    let firebaselis_anatilik = """
                  
              <html>
              <head>
              <meta charset='utf-8'>
              <meta name='viewport' content='width=device-width'>

              <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
              </head>
              <body>
              
              <br>
              <strong>Firebase</strong></br></br>


              <li>
              <a href="https://github.com/firebase/quickstart-ios/tree/master/analytics"><b>Firebase/Analytics</b></a></br>
              </li>
              <p>  Google Inc </p>
              <p>Licensed under the Apache License, Version 2.0 (the "License");
              You may not use this file except in compliance with the License.
              You may obtain a copy of the License at</p></br>

              <li>
                <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
              </li></br>

              <p> Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.</p></br>
              </body>
              </html>

              """
    let firebase_mes = """
                   
               <html>
               <head>
               <meta charset='utf-8'>
               <meta name='viewport' content='width=device-width'>

               <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
               </head>
               <body>
               
               <br>
               <strong>Firebase</strong></br></br>


               <li>
               <a href="https://github.com/firebase/quickstart-ios/tree/master/messaging"><b>Firebase/Messaging</b></a></br>
               </li>
               <p>  Google Inc </p>
               <p>Licensed under the Apache License, Version 2.0 (the "License");
               You may not use this file except in compliance with the License.
               You may obtain a copy of the License at</p></br>

               <li>
                 <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
               </li></br>

               <p> Unless required by applicable law or agreed to in writing, software
               distributed under the License is distributed on an "AS IS" BASIS,
               WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
               See the License for the specific language governing permissions and
               limitations under the License.</p></br>
               </body>
               </html>

               """
    
    let firebase_crash = """
                    
                <html>
                <head>
                <meta charset='utf-8'>
                <meta name='viewport' content='width=device-width'>

                <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
                </head>
                <body>
                
                <br>
                <strong>Firebase</strong></br></br>


                <li>
                <a href="https://github.com/firebase/quickstart-ios/tree/master/crashlytics"><b>Firebase/Crashlytics</b></a></br>
                </li>
                <p>  Google Inc </p>
                <p>Licensed under the Apache License, Version 2.0 (the "License");
                You may not use this file except in compliance with the License.
                You may obtain a copy of the License at</p></br>

                <li>
                  <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License</b></a>
                </li></br>

                <p> Unless required by applicable law or agreed to in writing, software
                distributed under the License is distributed on an "AS IS" BASIS,
                WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                See the License for the specific language governing permissions and
                limitations under the License.</p></br>
                </body>
                </html>

                """
    
    let webImage = """
         <html>
         <head>
         <meta charset='utf-8'>
         <meta name='viewport' content='width=device-width'>

         <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
         </head>
         <body>
         
         <br></br>
         <strong>SDWebImage</strong></br></br>


         <li>
           <a href="https://github.com/SDWebImage/SDWebImage"><b>SDWebImage/SDWebImage</b></a>
         </li>


         </br>
         
         <p>
         The MIT License (MIT)</br></p>

         <p>  Copyright (c) 2009-2018 Olivier Poitrey rs@dailymotion.com </br>

         <p> Permission is hereby granted, free of charge, to any person obtaining a copy
         of this software and associated documentation files (the "Software"), to deal
         in the Software without restriction, including without limitation the rights
         to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
         copies of the Software, and to permit persons to whom the Software is
         furnished to do so, subject to the following conditions:</p></br>

         <p>The above copyright notice and this permission notice shall be included in all
         copies or substantial portions of the Software.</p></br>

         <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
         IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
         FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
         AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
         LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
         OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
         SOFTWARE.</p></br>
         </body>
         </html>
         """
    
    
    let floatIcon = """
           <html>
           <head>
           <meta charset='utf-8'>
           <meta name='viewport' content='width=device-width'>

           <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
           </head>
           <body>
           
           <br></br>
           <strong>JJFloatingActionButton</strong></br></br>


           <li>
             <a href="https://github.com/jjochen/JJFloatingActionButton"><b>jjochen/JJFloatingActionButton</b></a>
           </li>


           </br>
           
           <p>
           The MIT License (MIT)</br></p>

           <p> Jochen Pfeiffer </br>

           <p> Permission is hereby granted, free of charge, to any person obtaining a copy
           of this software and associated documentation files (the "Software"), to deal
           in the Software without restriction, including without limitation the rights
           to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
           copies of the Software, and to permit persons to whom the Software is
           furnished to do so, subject to the following conditions:</p></br>

           <p>The above copyright notice and this permission notice shall be included in all
           copies or substantial portions of the Software.</p></br>

           <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
           IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
           FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
           AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
           LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
           OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
           SOFTWARE.</p></br>
           </body>
           </html>
           """
    
    let JDropDownAlert = """
       <html>
       <head>
       <meta charset='utf-8'>
       <meta name='viewport' content='width=device-width'>

       <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
       </head>
       <body>
       
       <br></br>
       <strong>JDropDownAlert</strong></br></br>


       <li>
         <a href="https://github.com/jjochen/JJFloatingActionButton"><b>trilliwon/JDropDownAlert</b></a>
       </li>


       </br>
       
       <p>
       The MIT License (MIT)</br></p>

       <p> Copyright (c) 2016 Steve Jo <trilliwon.io@gmail.com> </br>

       <p> Permission is hereby granted, free of charge, to any person obtaining a copy
       of this software and associated documentation files (the "Software"), to deal
       in the Software without restriction, including without limitation the rights
       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
       copies of the Software, and to permit persons to whom the Software is
       furnished to do so, subject to the following conditions:</p></br>

       <p>The above copyright notice and this permission notice shall be included in all
       copies or substantial portions of the Software.</p></br>

       <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
       SOFTWARE.</p></br>
       </body>
       </html>
       """
    
    let swProgres = """
          <html>
          <head>
          <meta charset='utf-8'>
          <meta name='viewport' content='width=device-width'>

          <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
          </head>
          <body>
          
          <br></br>
          <strong>SVProgressHUD</strong></br></br>


          <li>
            <a href="https://github.com/SVProgressHUD/SVProgressHUD"><b>SVProgressHUD/SVProgressHUD</b></a>
          </li>


          </br>
          
          <p>
          The MIT License (MIT)</br></p>

          <p>Copyright (c) 2011-2018 Sam Vermette, Tobias Tiemerding and contributors. </br>

          <p> Permission is hereby granted, free of charge, to any person obtaining a copy
          of this software and associated documentation files (the "Software"), to deal
          in the Software without restriction, including without limitation the rights
          to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
          copies of the Software, and to permit persons to whom the Software is
          furnished to do so, subject to the following conditions:</p></br>

          <p>The above copyright notice and this permission notice shall be included in all
          copies or substantial portions of the Software.</p></br>

          <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
          IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
          FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
          AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
          LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
          OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
          SOFTWARE.</p></br>
          </body>
          </html>
          """
    
    let dilaogPopup = """
            <html>
            <head>
            <meta charset='utf-8'>
            <meta name='viewport' content='width=device-width'>

            <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
            </head>
            <body>
            
            <br></br>
            <strong>PopupDialog</strong></br></br>


            <li>
              <a href="https://github.com/Orderella/PopupDialog"><b>Orderella/PopupDialog</b></a>
            </li>


            </br>
            
            <p>
            The MIT License (MIT)</br></p>

            <p>Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)</br>
            Author - Martin Wildfeuer (http://www.mwfire.de) </br></p>

            <p> Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:</p></br>

            <p>The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.</p></br>

            <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.</p></br>
            </body>
            </html>
            """
    
    let SwiftyAttributes = """
       <html>
       <head>
       <meta charset='utf-8'>
       <meta name='viewport' content='width=device-width'>

       <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
       </head>
       <body>
       
       <br></br>
       <strong>
       SwiftyAttributes</strong></br></br>


       <li>
         <a href="https://github.com/eddiekaiger/SwiftyAttributes"><b>eddiekaiger/SwiftyAttributes</b></a>
       </li>


       </br>
       
       <p>
       The MIT License (MIT)</br></p>

       <p>Copyright (c) 2015 Eddie Kaiger</p>

       <p> Permission is hereby granted, free of charge, to any person obtaining a copy
       of this software and associated documentation files (the "Software"), to deal
       in the Software without restriction, including without limitation the rights
       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
       copies of the Software, and to permit persons to whom the Software is
       furnished to do so, subject to the following conditions:</p></br>

       <p>The above copyright notice and this permission notice shall be included in all
       copies or substantial portions of the Software.</p></br>

       <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
       SOFTWARE.</p></br>
       </body>
       </html>
       """
    
    let msgController = """
       <html>
       <head>
       <meta charset='utf-8'>
       <meta name='viewport' content='width=device-width'>

       <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
       </head>
       <body>
       
       <br></br>
       <strong>
       JSQMessagesViewController</strong></br></br>


       <li>
         <a href="https://github.com/jessesquires/JSQMessagesViewController"><b>jessesquires/JSQMessagesViewController</b></a>
       </li>


       </br>
       
       <p>
       The MIT License (MIT)</br></p>

       <p>Copyright (c) 2014 Jesse Squires</br>

       http://www.hexedbits.com</p>

       <p> Permission is hereby granted, free of charge, to any person obtaining a copy
       of this software and associated documentation files (the "Software"), to deal
       in the Software without restriction, including without limitation the rights
       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
       copies of the Software, and to permit persons to whom the Software is
       furnished to do so, subject to the following conditions:</p></br>

       <p>The above copyright notice and this permission notice shall be included in all
       copies or substantial portions of the Software.</p></br>

       <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
       SOFTWARE.</p></br>
       </body>
       </html>
       """
    
    let ActiveLabel = """
       <html>
       <head>
       <meta charset='utf-8'>
       <meta name='viewport' content='width=device-width'>

       <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
       </head>
       <body>
       
       <br></br>
       <strong>
       ActiveLabel.swift</strong></br></br>


       <li>
         <a href="https://github.com/optonaut/ActiveLabel.swift"><b>optonaut/ActiveLabel.swift</b></a>
       </li>


       </br>
       
       <p>
       The MIT License (MIT)</br></p>

       <p>Copyright (c) 2015 Optonaut</p>

       <p> Permission is hereby granted, free of charge, to any person obtaining a copy
       of this software and associated documentation files (the "Software"), to deal
       in the Software without restriction, including without limitation the rights
       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
       copies of the Software, and to permit persons to whom the Software is
       furnished to do so, subject to the following conditions:</p></br>

       <p>The above copyright notice and this permission notice shall be included in all
       copies or substantial portions of the Software.</p></br>

       <p> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
       SOFTWARE.</p></br>
       </body>
       </html>
       """
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            lisansDisp.append(Lottie)
            lisansDisp.append(RevealingSplashView)
            lisansDisp.append(TweeTextField)
            lisansDisp.append(firebaselis)
            lisansDisp.append(firebaselis_auth)
            lisansDisp.append(firebaselis_firestore)
            lisansDisp.append(firebaselis_storage)
            lisansDisp.append(firebaselis_anatilik)
            lisansDisp.append(firebase_mes)
            lisansDisp.append(firebase_crash)
            lisansDisp.append(webImage)
            lisansDisp.append(floatIcon)
            lisansDisp.append(JDropDownAlert)
            lisansDisp.append(swProgres)
            lisansDisp.append(dilaogPopup)
            lisansDisp.append(SwiftyAttributes)
            lisansDisp.append(msgController)
            lisansDisp.append(ActiveLabel)
            view.backgroundColor = .white
            navigationItem.title = "Açık Kaynak Kütüphanleri"
            setNavigationBar()
            tableView.register(LicenceCell.self, forCellReuseIdentifier: id)
        tableView.separatorStyle = .none
    }
    
  // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! LicenceCell

        cell.name.text = datSource[indexPath.row]
               return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SingleLisans()
        vc.htmlString = lisansDisp[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
