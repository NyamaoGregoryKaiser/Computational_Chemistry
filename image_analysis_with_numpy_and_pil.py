# image_analysis.py

# Import necessary libraries
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np

# Load the image
picture = Image.open("example.jpeg")

# Display the image
plt.imshow(picture)
plt.axis('off')
plt.show()

# Convert image to an array and copy it for analysis
img_array = np.asarray(picture)
picture_array = img_array.copy()

# Display the shape of the array
print("Image shape:", picture_array.shape)
# The shape represents (height, width, color_channels), where color_channels is 3 for RGB

# Get basic pixel value information
print("Maximum pixel value:", picture_array.max())
print("Minimum pixel value:", picture_array.min())

# Separate RGB channels
red_array, green_array, blue_array = picture_array[:, :, 0], picture_array[:, :, 1], picture_array[:, :, 2]

# Plot each channel separately
plt.imshow(red_array, cmap="Reds")
plt.colorbar()
plt.title("Red Channel")
plt.show()

plt.imshow(green_array, cmap="Greens")
plt.colorbar()
plt.title("Green Channel")
plt.show()

plt.imshow(blue_array, cmap="Blues")
plt.colorbar()
plt.title("Blue Channel")
plt.show()

# Calculate average values for each color channel
print("Average red value:", red_array.mean())
print("Average green value:", green_array.mean())
print("Average blue value:", blue_array.mean())
