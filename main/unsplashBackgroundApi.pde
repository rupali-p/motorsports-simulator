import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import processing.data.JSONObject;

PImage unsplashImage; // Declare a variable to hold the Unsplash image
String accessKey = "" ; // please populate with your own
class Image{
  PImage image; 
  boolean exists;
}

class UnsplashImage {
  UnsplashImage(String query){
    // Load the Unsplash image
    JSONObject response = loadJSONObject("https://api.unsplash.com/search/photos?query=" + query + "&client_id=" + accessKey);
    JSONArray results = response.getJSONArray("results");
    if (results.size() > 0) {
      JSONObject firstImage = results.getJSONObject(0);
      String imageUrl = firstImage.getJSONObject("urls").getString("regular");
      unsplashImage = loadImage(imageUrl, "jpg");
  
      // Print the image URL to the console
      println("Unsplash Image URL: " + imageUrl);
    }
    
    //noLoop(); // Stops the sketch from continuously making requests
  }
  Image getBackground() {
    if (unsplashImage != null) {
      return new Image() {
        {
          image = unsplashImage;
          exists = true;
        }
      };
    } else {
      return new Image() {
        {
          exists = false;
        }
      };
    }
  }
}
