# EcoLens

## Workspace
* **Github Repository:** [https://github.com/irenefernandezz/EcoLens](https://github.com/irenefernandezz/EcoLens)
* **Releases:** [https://github.com/irenefernandezz/EcoLens/releases](https://github.com/irenefernandezz/EcoLens/releases)
* **SharePoint Workspace:** [https://upm365.sharepoint.com/sites/EcoLens/SitePages/CollabHome.aspx](https://upm365.sharepoint.com/sites/EcoLens/SitePages/CollabHome.aspx)

---

## Description

EcoLens is a cross-platform mobile application for Android and iOS designed to raise awareness about the environmental impact of the food products users consume.

At its core, the application allows users to scan product barcodes using the device camera or manually enter the barcode number. Once a product is identified, EcoLens displays a detailed analysis including the Eco-Score, NOVA group classification, number of additives, presence of palm oil, estimated CO₂ emissions, packaging materials, and potentially harmful or polluting ingredients.

In addition to these metrics, each product receives a global environmental rating, helping users quickly evaluate the sustainability of their purchases.

The application also stores a personalized history of scanned products, allowing users to review previous scans and access detailed information about each item at any time. In addition, there is a specific screen where users can share environmental tips with each other.

Beyond individual product analysis, EcoLens includes a dedicated statistics section where users can visualize their consumption habits through different metrics and charts. These include:

- The user’s average product score compared to the global average of all users.
- A progression graph showing the evolution of their scanning history over time.
- A pie chart summarizing scanned product categories or ratings.
- A recap of the user’s last five scanned products and their corresponding scores.

The app supports user authentication through both Google Sign-In and email registration, enabling persistent data storage.

Additionally, users can customize their profile by modifying their username and profile picture directly within the application.

## **Screenshots and navigation**
<table>
  <tr>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="1080" height="2340" alt="login" src="https://github.com/user-attachments/assets/390badaf-a06d-4619-83cd-004d80c1040e" />
      <br>
      <sub>Image 1: Log-in Screen
      <br>Users can choose to sign in with Google or with their email address
      </sub>
    </td>
     <td align="center" style="border:1px solid #ddd; padding:4px;">
       <img width="1080" height="2340" alt="register" src="https://github.com/user-attachments/assets/2ccfcf03-c37a-4cb5-9c0a-c08788662f09" />
      <br>
      <sub>Image 1: Register Screen
      <br>Users can create an account using their email address and a custom username.
      </sub>
    </td>
  </tr>
  <tr>
    <td align="center" style="border:1px solid #ddd; padding:4px;">
      <img width="945" height="2048" alt="WhatsApp Image 2026-05-18 at 15 59 41" src="https://github.com/user-attachments/assets/35d21791-0898-4165-ac15-64ef0903633e" />
      <br>
      <sub>Image 2: Home Screen
      <br>Main screen displaying the total number of scanned products, quick access to the latest scanned product, and the user profile picture. The bottom navigation bar provides access to the application's main sections.
      </sub>
    </td>
        <td align="center" style="border:1px solid #ddd; padding:4px;">
          <img width="945" height="2048" alt="WhatsApp Image 2026-05-18 at 15 59 422" src="https://github.com/user-attachments/assets/7cba121b-2ab0-4099-85db-2c8597d284aa" />
      <br>
      <sub>Image 3: Scan screen. 
        <br>Users can scan product barcodes directly using the device camera. The interface also allows switching to manual barcode input mode.
      </sub>
    </td>
    </tr>
    <tr>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="1080" height="2340" alt="manualmente" src="https://github.com/user-attachments/assets/a8a43f89-3973-4fca-aedf-73ad039d4a35" />
      <br>
      <sub>Image 4: Scan screen. 
      <br>Users can manually enter a product barcode if camera scanning is unavailable.
      </sub>
    </td>
     </td>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="945" height="2048" alt="rewards1" src="https://github.com/user-attachments/assets/6fc3926c-e5e9-4e8e-8f58-fa1fe454de54" />
      <br>
      <sub>Image 5: Rewards Screen. 
        <br> It shows the user and global average score and a progression graph.
      </sub>
    </td>
   </td>
  </tr>
  <tr>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="945" height="2048" alt="rewards2" src="https://github.com/user-attachments/assets/1ef1a155-87e3-401c-80e2-dd548fbd2ebb" />
      <br>
      <sub>Image 6: Rewards Screen.
        <br> Displays a pie chart summarizing scan distributions and a recap of the last five scanned products with their respective environmental scores.
      </sub>
    </td>
   </td>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="945" height="2048" alt="historial" src="https://github.com/user-attachments/assets/a264ac6d-6515-4bf6-ae9c-439ac4ac5f62" />
      <br>
      <sub>Image 6: History screen.
          <br> Displays the complete history of products scanned by the current user, allowing quick access to detailed product information.
      </sub>
    </td>
     </td>
  </tr>
  <tr>
      <td align="center" style="border:1px solid #ddd; padding:4px;">
        <img width="945" height="2048" alt="WhatsApp Image 2026-05-18 at 15 59 42" src="https://github.com/user-attachments/assets/96616561-c37d-4f3d-838e-df586f645077" />
      <br>
      <sub>Image 7: Profile Screen.
        <br>Users can modify their profile information, update their profile picture, log out, or permanently delete their account.
      </sub>
    </td>
  </tr>
</table>

## **Features**

**Functional features:**

- User Authentication & Profile Management: Users can register and log in using Google Sign-In or email authentication. User data is securely stored using Firebase services. Additionally, users can customize their profile by modifying their username and profile picture directly within the application.
- Barcode Scanning System: Products can be scanned directly using the device camera or introduced manually through their barcode number.
- Camera Permission Management: The application requests and manages camera access permissions dynamically, giving users full control over barcode scanning functionality.
- Environmental Product Analysis: Each scanned product displays detailed environmental information, including:
  - Eco-Score
  - NOVA classification
  - CO₂ emissions
  - Presence of palm oil
  - Number of additives
  - Packaging materials
  - Potentially polluting ingredients
  - Global environmental rating
- Personal Scan History: Users can access a complete history of previously scanned products and revisit the detailed analysis of any product at any time.
- Statistics & Trend Visualization: A dedicated statistics section allows users to monitor their environmental consumption habits through:
  - Personal average product score
  - Global average score comparison
  - Evolution graphs showing score progression over time
  - Pie charts summarizing scanning trends
  - A recap of the last five scanned products and their ratings
- Environmental tips: There is a section where users can post any type of environmental tip they wish, and it can be seen by any other user.
- Gamification System: EcoLens introduces a motivational system where users can compare their environmental performance against global averages and observe improvements in their consumption patterns over time.   

**Technical Features:**

- Cross-Platform Support: The application is available for both Android and iOS devices using a shared Flutter codebase.
- Programming Language: Dart.
- Framework: Flutter.
- Development Environment: Android Studio.
- Local Database Architecture: Implemented using SQLite through the `sqflite` package, with model classes and service layers for data management. The local database manages:
  - users: Stores user profile information.
  - products: Stores essential product information, including barcode data and locally calculated environmental scores. Additional product details are dynamically retrieved from the API.
  - product_user: Relational table connecting users with scanned products and storing scan timestamps.
- Firebase Integration:
  - Authentication: Supports user registration and login using both Google Sign-In and email/password authentication, maintaining a unique account instance for each user.
- Real time Firebase database: A database where eco-friendly tips are stored for real-time viewing. Each record includes the username and avatar of the user who made the comment, the tip itself, the date and time, and a list of users who liked the tip.
- Data Persistence (Local Storage): Uses SharedPreferences for lightweight session management and local storage of user-related information such as usernames and session states.
- External API Integration: Product information is retrieved through requests to the OpenFoodFacts API. A custom response parsing class has been developed to extract and structure only the relevant environmental and nutritional data required by the application.
- Dynamic Translation System: Uses the `translator` dependency to automatically translate ingredients, packaging materials, or product-related information whenever the API does not provide the content in English.
- Barcode Scanning System: Integrates the `MobileScanner` widget to access the device camera and perform real-time barcode scanning.
- Image Loading: Product images are dynamically loaded from external sources using Flutter’s `Image.network` widget.
- Custom Notifications: Uses the `toastification` package to display personalized toast notifications.
- Debugging & Logging: Implements the `logger` library for debugging.
- Navigation Mechanism: Screen transitions are handled using Flutter’s `Navigator.push` navigation system.
- Asynchronous Processing: Uses `Future` responses together with `async/await` operations to perform API calls and database operations without blocking the UI thread.

## **Demo video:**


## **How to use**

1. Open the project in Android Studio or Visual Studio Code.
2. Install the required Flutter dependencies:
  - flutter pub get
3. Build and run the application on either:
  - An Android emulator or physical device
  - An iOS simulator or physical device
4. Sign in or register using Google Sign-In or email and password authentication
5. Grant camera permissions when prompted by the system.
6. From the Home Screen, users can:
  - View the total number of scanned products
  - Access the most recently scanned product
  - Navigate through the application using the bottom navigation bar
  - Open the profile screen by tapping the profile picture or log out from the application
7. On the Scan Screen, users can scan product barcodes using the device camera or switch to manual barcode input mode
8. After scanning a product, users can view the product’s and environmental rating
9. On the Statistics Screen, users can compare their average score with the global average or view their own progression.
10. On the History Screen, users can access the complete scan history and open detailed information.
11. On the eco-tips screen, users can post environmental tips or read those posted by other users and "like" them.
12. On the Profile Screen, users can modify their data, log out or permanently delete their account.

## **Participants**

- Irene Fernández (irene.farellano@alumnos.upm.es)



