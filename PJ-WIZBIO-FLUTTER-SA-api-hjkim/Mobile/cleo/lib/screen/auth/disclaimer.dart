import 'package:flutter/material.dart';

class Disclaimer {
  static Widget privacy() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, height: 1.2),
              children: [
                buildDesc('Effective date: 05.24.2022'),
                buildDesc(
                    'Please read this Privacy Policy to learn how CLEO™ ONE (“CLEO™ ONE,” “we,” “us,” or “our”) operates with respect to the collection and use of personal information, including through our website (the “Website”) and our diagnostic testing device, mobile applications, or any CLEO™ ONE devices, applications, services, or websites, including our CLEO™ ONE services (collectively, the “Testing Platform”). We only collect personal information (meaning any information that identifies or can be used to identify you) through our Testing Platform and our Website as described in this Privacy Policy.\nThis Privacy Policy does not cover the collection and use of your information by third parties who may use CLEO™ ONE’s Testing Platform. Please review those third parties’ privacy policies and practices for further information.\nBy using or accessing our Website and Testing Platform, you acknowledge that you accept the practices and policies outlined below, along with our Terms of Use, which is incorporated by reference in its entirety, where and as permitted by applicable law. Any terms we use in this Policy without defining them have the definitions given to them in the Terms of Use.'),
                buildSubTitle('Your Account Information:'),
                buildDesc(
                    'When you use our Testing Platform, you may provide certain information directly to us. For example, when you register for an account to use our CLEO™ ONE services, we may collect the following information: an email address and password, first and last name, street address (including city, state, and zip code), and a phone number.'),
                buildSubTitle('Your Communication with Us:'),
                buildDesc(
                    'We collect information when you communicate with us. The specific types of information we collect will depend on the forum in which you communicate with us. For example, if you send us an email or fill out a contact form on our Website, we will collect your email address and the content of your email or form responses.'),
                buildSubTitle(
                    'What Information Do We Collect and How Do We Use It?'),
                buildDesc(
                  'The information we collect from you will depend on how you use our Testing Platform and our Website. Generally, we collect information directly from you when you voluntarily provide it to us.',
                ),
                buildSubTitle(
                  'Our Testing Platform:',
                ),
                buildSubTitle(
                  '1. Ask permission to access your mobile device camera',
                ),
                buildDesc(
                  'The Testing Platform will ask permission to access your mobile device camera to enable you to scan the code on your test cartridge or package. If you do not enable this permission, you will not be able to use the test platform. The Testing Platform only uses this permission while activating your test to obtain test cartridge information by reading the code if you choose to do so. The Testing Platform does not access any photos stored on your device and does not write to your device’s photo storage. Users who grant this permission can disable it at any time through their device’s app settings, but may not start the test if not enabled while performing a CLEO™ ONE test.',  //2023.10.16_CJH
                ),
                buildSubTitle(
                  '2. Ask permission to access GPS and to use location information',
                ),
                buildDesc(
                    "The CLEO™ ONE app collects location data even when the app is shut down or not in use, and the location data is used to connect the CLEO™ ONE device via the BLE. If required, we may collect information in connection with our governmental reporting obligations (which also includes deidentified demographic information) and zip code-level regions (or unidentified geographic units) of test results for public health reporting. We may also create de-identified information for internal, reporting and/or research purposes. The Test Platform may ask permission to use the location information or GPS information of the user's mobile device to get the user's consent."),
                buildSubTitle("3. Ask permission to use Bluetooth"),
                buildDesc(
                    "The Testing Platform will ask permission to use the mobile device Bluetooth to operate the CLEO ONE device and perform the Test. While the test is being performed, the mobile device uses Bluetooth to connect with CLEO ONE device. The App may check the Test process steps of the CLEO ONE device and obtain the test results by Bluetooth pairing communication with the device."),
                buildSubTitle("4. Ask permission to access storage"),
                buildDesc(
                    "The App stores user data only in the App storage and does not transfer to other Apps or external devices.\nThe App stores the test taker's name, date of birth, gender, location information provided by the mobile device, the serial number of the test device, lot information and expiration date of the test cartridge, and the date and time when the test was performed.\nIn order to write, read, and store test results transmitted from the test device with the user information collected by the App mentioned above, the App asks permission to access the storage of the mobile device.\nThe App stores the user data to let a user view performed previous test results and is not provided for transferring to the external App.\nThe App stores your test results (“positive,” “negative” or “invalid” results) and your test records in the App storage. If the user deletes the App, the user may permanently lose the previous test results stored in the app storage."),
                buildSubTitle("Information Received From Third Parties:"),
                buildDesc(
                    "CLEO™ ONE receives information from third party providers as part of delivery and operational services necessary to provide customers with the expected functionality of the Testing Platform. These partners include, but are not limited to: physicians who provide lab testing requisitions and telehealth services.\nInformation from Cookies and Similar Technologies.\nA cookie is a small piece of data that a website can send to your computer's internet browser, which is then stored on your computer's operating system. Cookies are how websites recognize users and keep track of their preferences. We and third-party partners collect information using cookies, pixel tags, or similar technologies. Our third-party partners, such as analytics and advertising partners, may use these technologies to collect information about your online activities over time and across different services. Please review your web browser's \"Help\" file to learn the proper way to modify your cookie settings. Please note that if you delete or choose not to accept cookies from the Website, you may not be able to utilize the features of the Website to their fullest potential.\nPlease note that because there is no consistent industry understanding of how to respond to “Do Not Track” signals, we do not alter our data collection and usage practices when we CLEO™ ONE such a signal from your browser. When our website cleo1.net a Do Not Track signal from your browser, it will still collect referring and exit page information and other information when you visit our website."),
                buildSubTitle(
                  'Information Automatically Collected',
                ),
                buildDesc(
                    'As with most apps and websites, when you use our Website or Testing Platform we automatically receive and collect information about you and your device. This information includes the following:'),
                buildDesc(
                  '•	Information about your device, such as the operating system, hardware, system version, the Internet Protocol (IP) address, device ID, and device language.\n•	The specific actions that you take when you use our Website or Testing Platform, including but not limited to: the pages and screens that you view or visit, search terms that you enter, and how you interact with our Website or Testing Platform.\n•	The time, frequency, connection type, and duration of your use of our Website or Testing Platform.\n•	Information about your wireless and mobile network connections, such as mobile phone number, service provider, and signal strength.\n•	Location information, such as GPS information.\n•	Information regarding your interaction with email messages, for example, whether you opened, clicked on, or forwarded the email message.\n•	Identifiers associated with cookies or other technologies that may uniquely identify your device or browser (as further described below); and\n •	Pages you visited before or after navigating to our Website.',
                ),
                buildSubTitle('How We Use Your Information'),
                buildDesc(
                  "In general, we collect personal information from you so that we can provide our Website and Testing Platform, operate our business, and provide information that you request from us. This includes the following uses and purposes:",
                ),
                buildDesc(
                    "•	Create and administer your account.\n•	Provide testing services via our CLEO™ ONE services.\n•	Provide, operate, improve, maintain, and protect our Website and Testing Platform.\n•	Provide you with technical and other support.\n•	Send you services and company updates, marketing communication, service information, and other information about our company and our services, and products and services of third parties that we think you may be interested in.\n•	Conduct research and analysis, and monitor and analyze trends and usage.\n•	Enhance or improve user experience, our business, and our services, including the safety and security thereof.\n•	Send you push notifications through our mobile app.\n•	Personalize our services to you.\n•	Communicate with you and respond to inquiries.\n•	Operate our business and perform any other function that we believe in good faith is necessary to protect the security or proper functioning of our Website and Testing Platform.\n•	As necessary to comply with any applicable law, regulation, subpoena, legal process, or governmental request.\n•	Enforce contracts and applicable Terms of Use, including investigation of potential violations thereof.\n•	CLEO™ ONE, prevent, or otherwise address fraud, security or technical issues.\n•	Protect against harm to the rights, property or safety of CLEO™ ONE, our users, customers, or the public as required or permitted by law.\n"),
                buildSubTitle(
                  'How Do We Share Information?',
                ),
                buildDesc(
                  'We do not share your personal information except as described in this Privacy Policy, unless we have your consent or permission to do so. In connection with our Testing Platform, if required, we also share information for purposes of governmental reporting.',
                ),
                buildSubTitle('Third Party Vendors'),
                buildDesc(
                    'We may have contractual agreements with affiliates, services providers, partners, and other third parties who may use the information described in this policy to operate our Website, and to develop, market, and provide our products. Any information collected or used by third party vendors is limited to the collection described in this policy, and may be used only for the purposes described. Additionally, if you use our CLEO™ ONE services, we may contract with third-party laboratories. Please note that laboratories may be subject to mandatory governmental reporting obligations, so information relating to those test results may be disclosed to governmental agencies where required.'),
                buildSubTitle('Change in Control or Sale'),
                buildDesc(
                    'We may choose to buy or sell assets, and may share and/or transfer customer information in connection with the evaluation of and entry into such transactions. Also, if we (or our assets) are acquired, or if we go out of business, enter bankruptcy, or go through some other change of control, Personal Information could be one of the assets transferred to or acquired by a third party. However, we note that any entity acquiring our business or assets would have an obligation to use the Personal Information that comes with it strictly in accordance with this Privacy Policy. You acknowledge that such transfers may occur, and that any acquirer of us or our assets may continue to use your Personal Information only as set forth in this policy, unless you are informed otherwise.'),
                buildSubTitle('Legal Process, Security, Defense, Protection'),
                buildDesc(
                    'Occasionally, we may be required to share information with third parties for legitimate business purposes, or to comply with legal obligations. For example, we may share information when we believe in good faith that an applicable law requires it; at the request of law enforcement, judicial authorities (e.g. upon receipt of a court order or subpoena), or appropriate governmental authorities; to CLEO™ ONE and protect against fraud, or any technical or security vulnerabilities; to respond to an emergency; or otherwise to protect the rights, property, safety or security of third parties, visitors to our Website, our businesses, or the public. We may also disclose personal information when requested by state and federal governmental authorities or related entities to assist in efforts to track virus infections.'),
                buildSubTitle('Retention of Personal Information'),
                buildDesc(
                    'We generally retain your information as long as necessary to provide relevant services to you, comply with our legal and internal retention obligations and procedures, comply with governmental reporting obligations, and as permitted by law.'),
                buildSubTitle('Security of Your Information'),
                buildDesc(
                    'We use reasonable security measures, including measures designed to protect against unauthorized or unlawful processing and against accidental loss, destruction or damage to your personal information. We also take certain measures to enhance the security of our services, however, since the Internet is not a 100% secure environment, we cannot guarantee, ensure, or warrant the security of any information you transmit to us. There is no guarantee that information may not be accessed, disclosed, altered, or destroyed by breach of any of our physical, technical, or managerial safeguards. It is your responsibility to protect the security of your login information.'),
                buildSubTitle('Your Privacy Choices'),
                buildDesc(
                    'Individuals who create an account through our Website or Testing Platform can access and amend that information by logging into their account. Users who wish for CLEO™ ONE to delete all information about them should contact info@wizbiosoluiton.com or call +82 (70)7605 5066. Please note that in some cases we may not be able to delete some or all of your information.'),
                buildSubTitle('Children'),
                buildDesc(
                    'Our Website and Testing Platform are not directed at children under 13, and we do not knowingly collect personal information from children under 13. If you are under 13, please do not attempt to use our Website or Testing Platform or send any information about yourself to us. If you are the parent of a child under the age of 13, and you believe he or she has shared personal information with us, please contact us at info@wizbiosolution.com so that we can remove such information from our systems.'),
                buildSubTitle('Changes to the Privacy Policy'),
                buildDesc(
                    'We reserve the right to revise this Privacy Policy at any time by amending this page and changes will be effective upon being posted unless we advise otherwise. If we make any material changes to this Privacy Policy, we will notify you by means of a notice on our Website prior to the change becoming effective. If you do not accept the terms of this Privacy Policy, we ask that you discontinue use of our Website and Testing Platform.'),
                buildSubTitle('Contact'),
                buildDesc(
                    'If you have questions on the processing of your personal information, or have a complaint, please contact us here: info@wizbiosolution.com'),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Widget buildTerms() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLEO ONE TERMS OF USE AND END USER LICENSE AGREEMENT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, height: 1.2),
              children: [
                buildDesc('Updated March 23, 2022'),
                buildDesc(
                    'Welcome to the CLEO ONE Terms of Use (“Terms of Use”) by Wizbiosolutions Inc. (“Wizbiosolution,” “CLEO” “our” “we” or “us”). These Terms of Use and End User License Agreement (collectively “Terms”) govern your use of the CLEO ONE Products (the “Wizbiosolutions Products”).'),
                buildDesc(
                    'Please read these Terms in full before using the CLEO ONE Products. By using the CLEO ONE Products, you agree to be legally bound by these Terms, any amendments of the Terms, and all applicable Wizbiosolutions rules and policies, including the Wizbiosolutions Privacy Policy. If you do not agree to these Terms, do not use the CLEO ONE Products.'),
                buildSubTitle('Modifications To These Terms'),
                buildDesc(
                    'We reserve the right to modify these Terms at any time, in our sole discretion, without prior notice to you, and your use of the CLEO ONE Products binds you to the use of the changes made. We do occasionally update these Terms, so please refer to them in the future. If you do not agree to the amended Terms, your sole and exclusive remedy is to cease use of the CLEO ONE Products. By continuing to access the CLEO ONE Products after the Terms have amended, you agree and consent to such amendments. Features and specifications of the CLEO ONE Products described or depicted herein are subject to change at any time without notice.'),
                buildSubTitle('The CLEO Products'),
                buildDesc(
                    'These Terms apply to your use of any of the CLEO Products. You will not use any of the CLEO Products in a manner inconsistent with (i) these Terms or (ii) any and all applicable laws and regulations. The CLEO Products that are governed by these Terms are described below:'),
                buildSubTitle('This CLEO ONE Product includes the following:'),
                buildDesc(
                    '    •    CLEO ONE System: CLEO ONE device, Power Adapter Cable'),
                buildDesc(
                    '    •    CLEO ONE Test Cartridge Pack: single-use CLEO ONE Test Cartridge and single-use Sample swab and single-use buffer tube'),
                buildDesc(
                    '    •    CLEO ONE Mobile Application (“CLEO ONE App”): available for download from the Apple® App Store® and Google Play™ Store onto a compatible smart device.'),
                buildDesc(
                    'The CLEO ONE App provides you with step-by-step instructions on how to insert the CLEO ONE Test Cartridge into the CLEO ONE device, collect specimens using a Sample swab, insert the Sample swab into the buffer tube, mixing buffer tube and insert buffer tube into the CLEO ONE cartridge and run the test (collectively the “CLEO ONE Virus Test”). In order for you to run a NEW Test, the CLEO ONE App need to connect with available CLEO ONE close to your mobile smart device via BLUETOOTH® connection. The Help Center within the CLEO ONE App provides additional instructional documentation for you to view. '),
                buildSubTitle('Your CLEO ONE Account'),
                buildDesc(
                    'When you install the CLEO ONE App on a mobile smart device and register for an account, you will be asked to set up a profile. You may set up multiple profiles in your account for your patients (for laboratories/health care providers/health care professionals) and/or your children, family members, or others (for consumers) and may save CLEO ONE Test results under any of these profiles.  The CLEO ONE App will display historical test results for each profile.'),
                buildDesc(
                    'By creating a CLEO ONE App account, you represent and warrant the following: (a) you are an adult of at least 18 years of age (or an adult under applicable state law), (b) you have the legal ability and authority to enter into these Terms, (c) you have provided accurate and complete information when establishing your account and creating profiles (“Registration Information”), (d) you have the authority and consent of any individual if you create a profile on their behalf, (e) to the extent you create a profile on behalf of another individual, such individual has reviewed and agreed to the terms of the CLEO ONE Privacy Policy, (f) you will take all reasonable steps necessary to maintain and promptly update the Registration Information to ensure that it is accurate and complete.'),
                buildDesc(
                    'If you provide any information that is untrue or inaccurate about yourself or others for whom you establish a profile, or CLEO ONE has reasonable grounds to suspect that such information is untrue or inaccurate, CLEO ONE may suspend or terminate your account immediately.'),
                buildDesc(
                    'Additionally, you agree to maintain the strict confidentiality of your account and any passwords created by you for your use of the CLEO ONE Products, and you agree not to allow persons or entities to use any username(s) or password(s) that are created by you. You alone shall be responsible for all of the activity that occurs in your account, including failure to obtain the proper consent from any individuals for whom you created an account. We cannot and will not be liable for any loss or damage arising from your failure to comply with these obligations. If you wish to cancel a username or password, or if you become aware of any loss, theft or unauthorized use of a username or password, please notify us immediately. We reserve the right to delete or change any username or password at any time and for any reason.'),
                buildDesc(
                    'The CLEO ONE App is not intended for use by children under the age of 13. If you are under 13 years of age, consent from a parent or guardian is required. CLEO ONE does not seek to gather personal information from or about persons under the age of 13 without the consent of a parent or guardian.'),
                buildSubTitle('Use Of the CLEO ONE Products'),
                buildDesc(
                    'As a user of the CLEO ONE Products, you acknowledge that:'),
                buildDesc(
                    '    •    It is your responsibility to use the CLEO ONE App appropriately to obtain the results of the CLEO ONE Test. Wizbiosolutions is not responsible if you do not use the CLEO ONE App and the CLEO ONE Test as directed.'),
                buildDesc(
                    '    •    It is very important to read the CLEO ONE User Manual and the Instructions for Use for the specific CLEO ONE Test being used, which include the indications and contraindications for use of such CLEO ONE Product.'),
                buildDesc(
                    '    •    You will not use these products for any purposes prohibited by United States law, or Rep. of Korea law and Eu Countries law. '),
                buildSubTitle('Privacy'),
                buildDesc(
                    'We are committed to maintaining the privacy of any information that you elect to provide through the CLEO ONE App (“Personal Information”). Please refer to our Privacy Policy, which is available in the CLEO ONE App and on the Cleo1 Website, for a full description of the Personal Information that we collect and how we use that information. Personal Information will be used by Wizbiosolutions solely in accordance with these Terms and the Privacy Policy.'),
                buildSubTitle('License to Use the CLEO ONE App'),
                buildDesc(
                    'The CLEO ONE App and any third party software, documentation, or interfaces accompanying this License are licensed, not sold, to you. Except for the limited license granted in this Agreement, CLEO ONE retains all right, title and interest in the CLEO ONE App, including copyrights, patents, trademarks and trade secret rights.'),
                buildDesc(
                    'Wizbiosolutions grants you a revocable, nontransferable, nonexclusive license to use the CLEO ONE Products as described in these Terms. You may download the CLEO ONE App on your mobile smart device and use the CLEO ONE Products, as permitted by these Terms.'),
                buildSubTitle(
                    'Limitations On License. The license granted to you in this Agreement is restricted as follows:'),
                buildDesc(
                    '    •    Limitations On Copying And Distribution. You may not copy or distribute the CLEO ONE App except to the extent that copying is necessary to use the CLEO ONE App for purposes set forth herein.'),
                buildDesc(
                    '    •    Limitations On Reverse Engineering And Modification; APIs. You may not (i) access or use the CLEO ONE App programming interfaces (“APIs”) for any purpose other than your licensed use of the CLEO ONE App, (ii) reverse engineer, decompile, disassemble, attempt to derive the source code of, or modify or create works derivative of the CLEO ONE App, any updates or part thereof, except to the extent expressly permitted by applicable law.'),
                buildDesc(
                    '    •    Sublicense, Rental And Third Party Use. You may not assign, transfer, sublicense, rent, timeshare, loan, lease or otherwise transfer the CLEO ONE App, or directly or indirectly permit any third party to copy and install the CLEO ONE App on a device not owned and controlled by you. If you transfer ownership of your mobile smart device, you must delete the CLEO ONE App from the mobile smart device before doing so.'),
                buildDesc(
                    '    •    Individual Use. You may not distribute or make the CLEO ONE App available over a network where it could be used by multiple devices at the same time. The CLEO ONE App must be downloaded on each mobile smart device.'),
                buildDesc(
                    '    •    Proprietary Notices. You may not remove any proprietary notices (e.g., copyright and trademark notices) from CLEO ONE App or its documentation.'),
                buildDesc(
                    '    •    Use In Accordance With Documentation. All use of the CLEO ONE App must be in accordance with its then current documentation, including user guides, which can be found within the CLEO ONE App.'),
                buildDesc(
                    '    •    Confidentiality. You must hold the CLEO ONE App and any related documentation in strict confidence.'),
                buildDesc(
                    '    •    Compliance With Applicable Law. You are solely responsible for ensuring your use of the CLEO ONE App is in compliance with all applicable foreign, federal, state and local laws, and rules and regulations.'),
                buildSubTitle('Ownership Of Materials And Restrictions On Use'),
                buildDesc(
                    'Wizbiosolutions is, unless otherwise stated, the owner of all copyright, trademark, patent, trade secret, database and other proprietary rights to information on the CLEO ONE Products, including without limitation, the CLEO ONE App. Our Products and all other material provided and the collection and compilation and assembly thereof are the exclusive property of Wizbiosolutions, and are protected by U.S. and international copyright laws. If any product name or logo does not appear with a trademark (TM), that does not constitute a waiver of intellectual property rights that Wizbiosolutions has established in any of its products, services, features, or service names or logos.'),
                buildDesc(
                    'You agree to observe copyright and all other applicable laws and may not use the content in any manner that infringes or violates the rights of any person or entity, is unlawful in any jurisdiction where the CLEO ONE Products are being used, or prohibited by these Terms. You agree not to use the CLEO ONE Products in any manner that could damage, disable, overburden, or impair any of our equipment or interfere with any other party’s use and enjoyment of the CLEO ONE Products, or any contents of the CLEO ONE Products. You may not attempt to gain access to any portion of the CLEO ONE Products other than those for which you are authorized.'),
                buildSubTitle('CLEO ONE Products Availability'),
                buildDesc(
                    'We take all reasonable steps to ensure that the CLEO ONE Products are available 24 hours every day, 365 days per year. However, mobile applications do sometimes encounter downtime due to server and other technical issues as well as issues beyond our reasonable control. Where possible, we will try to give our users advance warning of maintenance issues, but shall not be obliged to do so. We will not be liable if the CLEO ONE Products are unavailable at any time.'),
                buildDesc(
                    'While every effort is made to ensure that all content provided on the CLEO ONE Products do not contain computer viruses and/or harmful materials, you should take reasonable and appropriate precautions to protect your mobile smart device, and you should ensure that you have a complete and current backup of the applicable items on your mobile smart device. We disclaim any liability for the need for services or replacing equipment or data resulting from your use of the CLEO ONE Products. While every effort is made to ensure smooth and continuous operation, we do not warrant the CLEO ONE Products will operate error free.'),
                buildSubTitle('Disclaimers'),
                buildDesc(
                    'THE INFORMATION PROVIDED IS NOT INTENDED TO TREAT, CURE, OR PREVENT ANY DISEASE BUT TO ASSIST YOU IN A DIAGNOSIS THROUGH USE OF THE CLEO ONE TEST.'),
                buildSubTitle('FOR HEALTHCARE PROVIDERS, PLEASE READ:'),
                buildDesc(
                    'THE CLEO ONE PRODUCTS ARE DESIGNED TO HELP YOU, BUT YOU SHOULD EXERCISE YOUR OWN CLINICAL JUDGMENT WHEN USING THE CLEO ONE PRODUCTS (CONTENT AND TOOLS). THE CONTENT AND TOOLS PROVIDED BY THE CLEO ONE PRODUCTS DO NOT CONSTITUTE INDEPENDENT MEDICAL ADVICE. CLEO ONE IS NOT ENGAGED IN THE PRACTICE OF MEDICINE.'),
                buildSubTitle('FOR CONSUMERS, PLEASE READ:'),
                buildDesc(
                    'IF YOU EXPERIENCE A MEDICAL EMERGENCY, STOP USING THE CLEO ONE PRODUCTS AND CALL 119. YOU ACKNOWLEDGE THAT THE INFORMATION PROVIDED THROUGH OUR CONTENT AND TOOLS ARE NOT INTENDED, OR TO BE CONSTRUED, AS INDEPENDENT MEDICAL ADVICE OR TREATMENT, AND IS NOT A SUBSTITUTE FOR CONSULTATIONS WITH QUALIFIED HEALTH CARE PROFESSIONALS WHO ARE FAMILIAR WITH YOUR INDIVIDUAL MEDICAL NEEDS. CLEO ONE IS NOT ENGAGED IN THE PRACTICE OF MEDICINE.'),
                buildDesc(
                    'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE CLEO ONE PRODUCTS ARE PROVIDED “AS IS” AND “AS AVAILABLE,” WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND, AND WIZBIOSOLUTIONS HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH RESPECT TO THE CLEO ONE PRODUCTS, EITHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES AND/OR CONDITIONS OF MERCHANTABILITY, OF SATISFACTORY QUALITY, OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY, OF QUIET ENJOYMENT, AND OF NON-INFRINGEMENT OF THIRD-PARTY RIGHTS. WITHOUT LIMITATION THEREOF, WE DO NOT WARRANT AGAINST INTERFERENCE WITH YOUR ENJOYMENT OF THE CLEO ONE PRODUCTS OR THE FUNCTIONS CONTAINED IN, OR SERVICES PERFORMED OR PROVIDED BY THE CLEO ONE PRODUCTS WILL MEET YOUR REQUIREMENTS, THAT THE OPERATION OF THE CLEO ONE PRODUCTS WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT DEFECTS IN THE CLEO ONE PRODUCTS WILL BE CORRECTED. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY WIZBIOSOLUTIONS OR ITS AUTHORIZED REPRESENTATIVES SHALL CREATE A WARRANTY. SHOULD THE CLEO ONE APP PROVE DEFECTIVE, YOU ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES OR LIMITATIONS ON APPLICABLE STATUTORY RIGHTS OF A CONSUMER, SO THE ABOVE EXCLUSION AND LIMITATIONS MAY NOT APPLY TO YOU.'),
                buildDesc(
                    'You acknowledge and agree to assume full responsibility for the risks associated with the use of the CLEO ONE Products, and that the use of such is at your sole risk. Wizbiosolutions is not liable to you, or any third party, for any decision made or action taken by you or any third party based on information contained on or within the CLEO ONE Products; or, due to reliance upon information contained on or within the CLEO ONE Products. You are solely responsible for verifying the accuracy of all personal information contained within the CLEO ONE Products and for obtaining the consent of those for whom you create a profile on their behalf. Wizbiosolutions is not responsible for any loss of the data entered into the CLEO ONE App if you lose your mobile smart device or delete the mobile application. You are solely responsible for any data fees on your mobile smart device or charges incurred related to your transfer of data via the internet.'),
                buildDesc(
                    'Wizbiosolutions, its suppliers and licensors shall have no liability for errors, unreliable operation, or other issues resulting from use of the CLEO ONE Products on or in connection with rooted or jail broken devices or use on any mobile smart device that is not in conformance with the manufacturer’s original specifications, including use of modified versions of the operating system (collectively, “Modified Devices”). Use of the CLEO ONE App on Modified Devices will be at your sole and exclusive risk and liability.'),
                buildDesc(
                    'In addition, Wizbiosolutions expressly disclaims any liability and is not responsible, and you acknowledge and agree that Wizbiosolutions is not liable or responsible for: (a) any errors in data or data entry, whether caused by you or by hardware, software or otherwise; (b) errors in results, (c) errors in diagnostic or therapeutic conclusions relying on erroneous data or data entry; (d) malfunction or loss of use of any hardware or software; (e) loss or degradation of communications between you, the CLEO ONE Products, and/or Wizbiosolutions for any reason not within control of CLEO ONE; (f) personal injury; (g) your failure to correct erroneous data or to comply with proper instructions; (h) delay, failure, interruption or corruption of data, and (i) errors resulting from unauthorized access to the CLEO ONE Products.'),
                buildSubTitle('Limitation Of Liability'),
                buildDesc(
                  'UNDER NO CIRCUMSTANCES SHALL Wizbiosolutions OR ITS OFFICERS, DIRECTORS, EMPLOYEES, AGENTS, REPRESENTATIVES, SUPPLIERS, OR LICENSORS BE RESPONSIBLE FOR PERSONAL INJURY OR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, SPECIAL, OR PUNITIVE DAMAGES OR LOSSES, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, LOSS OF DATA, BUSINESS INTERRUPTION, OR ANY OTHER COMMERCIAL DAMAGES OR LOSSES, ARISING OUT OF OR RELATED TO YOUR USE OF OR INABILITY TO USE THE CLEO ONE PRODUCTS OR YOUR RELIANCE ON OR USE OF THE CLEO ONE PRODUCTS, HOWEVER CAUSED, REGARDLESS OF THE THEORY OF LIABILITY (CONTRACT, TORT, OR OTHERWISE) AND EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. NOTWITHSTANDING ANYTHING ELSE IN THIS AGREEMENT, THE AGGREGATE LIABILITY OF Wizbiosolutions TO YOU ARISING UNDER OR IN CONNECTION WITH THESE TERMS IS LIMITED TO THE GREATER OF (1) THE AMOUNT THAT YOU PAID TO Wizbiosolutions FOR THE CLEO ONE TEST ON WHICH THIS DISPUTE IS BASED IN THE PAST SIX (6) MONTHS OR \$25.00, WHICHEVER IS GREATER. If you live in a jurisdiction that does not allow any of the above exclusions or limitations of liability or any of the disclaimers of warranties above, such exclusions or limitations will not apply to you, but only to the extent such exclusions or limitations are not allowed. In no event shall Wizbiosolutions be liable to you for damages (other than as may be required by applicable law in cases involving personal injury). The foregoing limitations will apply even if the above stated remedy fails of its essential purpose.',
                ),
                buildSubTitle('Indemnification'),
                buildDesc(
                    'You agree to defend, indemnify, and hold Wizbiosolutions, our officers, directors, employees, volunteers, agents, and contractors harmless from and against any claims, actions or demands, liabilities and settlements, including without limitation, legal and accounting fees, resulting from or alleged to result from, your use of and access to the CLEO ONE Products, your violation of these Terms or your violation of any third party right, including without limitation any trademark, copyright or other proprietary or privacy right, any claim for personal injury, death or damage to property, or breach or loss of data that you (or unauthorized users using your account) have transmitted, uploaded, downloaded, stored, managed or in any other way accessed, using the CLEO ONE Products. Wizbiosolutions reserves the right to assume the exclusive defensive and control of any matter subject to indemnification by you (without limiting your indemnification obligations with respect to the matter).  In that case, you agree to cooperate with our defenses of those claims.'),
                buildSubTitle('Third Party Content/Liability'),
                buildDesc(
                    'These Terms are only applicable to the use of the CLEO ONE Products. The CLEO ONE App may enable access to third-party services and websites (“External Services”). We do not have any control over External Services, and as such, Wizbiosolutions, its suppliers and licensors, disclaim all liability from your use of those External Services. Any link on or within the CLEO ONE Products to another site is not an endorsement of such other site. No judgment or warranty is made with respect to the accuracy, timeliness, or suitability of the content of any site to which we may link, and we take no responsibility for it. To the extent you choose to use such External Services, you agree to use such services at your sole risk and you are solely responsible for compliance with any applicable laws. Wizbiosolutions reserves the right to change, suspend, remove, disable or impose access restrictions or limits on any External Services at any time without notice or liability to you.'),
                buildDesc(
                    'Your wireless carrier, the manufacturer and retailer of your mobile smart device, the developer of the operating system for your mobile smart device, the operator of any application store, marketplace, or similar service through which you obtain the CLEO ONE App, and their respective affiliates, suppliers, and licensors are not parties to this Agreement and they do not own and are not responsible for the CLEO ONE App. You are responsible for complying with all of the application store and other applicable terms and conditions by these or other sites or services.'),
                buildSubTitle('Termination'),
                buildDesc(
                    'Wizbiosolutions may terminate your access to all or any part of the CLEO ONE Products in the event of any breach of these Terms. In addition, Wizbiosolutions may choose to discontinue support of the CLEO ONE Products at any time, without notice. In such case, the CLEO ONE Products may cease to function and your data that are stored on the cloud server may become inaccessible. You are solely responsible for saving locally any data stored in the CLEO ONE App. All provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity and limitations of liability.'),
                buildSubTitle('Governing Law'),
                buildDesc(
                    'We make no representations that the content or the CLEO ONE Products are appropriate or may be used or downloaded outside the United States, EU Countries, Rep. of Korea. Access to the CLEO ONE Products and/or the content may not be legal in certain countries outside the United States, EU Countries, Rep. of Korea. If you access the CLEO ONE Products from outside the United States, EU Countries, Rep. of Korea, you do so at your own risk and are responsible for compliance with the laws of the jurisdiction from which you access the website.'),
                buildDesc(
                    'Any dispute with respect to the CLEO ONE Products shall be governed by the laws of Rep. of Korea, excluding its conflicts of laws rules. You agree to submit to the personal and exclusive jurisdiction of the courts located within Seoul, Rep. of Korea to resolve any dispute or claim arising from this Agreement. We may seek injunctive or other equitable relief in any jurisdiction in order to protect our intellectual property rights.'),
                buildDesc(
                    'YOU HEREBY IRREVOCABLY WAIVE ANY AND ALL RIGHT TO TRIAL BY JURY OR TO PARTICIPATE IN ANY CLASS ACTION OR LEGAL PROCEEDING ARISING OUT OF OR RELATING TO THESE TERMS OF USE AND/OR PRIVACY STATEMENT. YOU AGREE THAT ANY CAUSE OF ACTION ARISING OUT OF OR RELATED TO THE CLEO ONE PRODUCTS MUST COMMENCE WITHIN ONE (1) YEAR AFTER THE CAUSE OF ACTION ACCRUES. OTHERWISE, SUCH CAUSE OF ACTION IS PERMANENTLY BARRED.'),
                buildSubTitle('General'),
                buildDesc(
                    'These Terms and any amendments thereof, any licensing agreements, together with applicable CLEO ONE policies and procedures, including the Privacy Policy and any legal notices that we publish regarding the CLEO ONE Products shall constitute the entire agreement between us concerning use of the CLEO ONE Products. If any provision of these Terms is deemed invalid by a court of competent jurisdiction, the invalidity of such provision shall not affect the validity of the remaining provisions of these Terms, which shall remain in full force and effect. No waiver of any term shall be deemed a further or continuing waiver of such term or any other term, and our failure to assert any right or provision under these Terms shall not constitute a waiver of such right or provision.'),
                buildSubTitle('Contact Us'),
                buildDesc(
                    'If you have any questions, concerns, or suggestions or otherwise need to contact us, please email us at info@wizbiosolution.com, call us at +82-70-7013-5066, or by regular mail at Wizbiosolutions, Inc., A1806, Woolim Lions Valley2, Sagimakgol-ro, 45beon-gil 14, Seongnam, Republic of Korea, 13209, Attn: Legal Department.'),
                buildDesc(
                    'CLEO™ ONE and CLEO™ are registered trademarks of Wizbiosolutions, Inc.'),
                buildDesc(
                    'Apple and App Store are registered trademarks of Apple Inc., registered in the U.S. and other countries and regions.'),
                buildDesc(
                    'Google Play is a trademark of Google LLC.\nOther trademarks and trade names are those of their respective owners.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextSpan buildSubTitle(String text) {
    return TextSpan(
        text: '$text\n\n',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ));
  }

  static TextSpan buildDesc(String text) {
    return TextSpan(text: '$text\n\n', style: const TextStyle());
  }
}
