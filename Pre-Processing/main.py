import os
import numpy as np
from sklearn.decomposition import PCA
from matplotlib.image import imread
import matplotlib.pyplot as plt
from PIL import Image, ImageFile
from sklearn.cluster import KMeans
ImageFile.LOAD_TRUNCATED_IMAGES = True

FIRE_SOURCE_PATH = "../../Datasets/Fire_Raw/"
SMOKE_SOURCE_PATH = "../../Datasets/Smoke_Raw/"
SPARE_SOURCE_PATH = "../../Datasets/Spare_Raw/"

FIRE_RESIZE_PATH = "/Users/rushivarora/Documents/Honors Project/Datasets/Fire_Resize/"
SMOKE_RESIZE_PATH = "/Users/rushivarora/Documents/Honors Project/Datasets/Smoke_Resize/"
SPARE_RESIZE_PATH = "/Users/rushivarora/Documents/Honors Project/Datasets/Spare_Resize/"

FIRE_DEST_PATH = "../../Datasets/Final/Fire/"
SMOKE_DEST_PATH = "../../Datasets/Final/Smoke/"
SPARE_DEST_PATH = "../../Datasets/Final/Fire/Spare"

numFire = 987
numSmoke = 781
numSpare = 878

length = 512
width = 256

sourcePaths = [FIRE_SOURCE_PATH, SMOKE_SOURCE_PATH, SPARE_SOURCE_PATH]
resizePaths = [FIRE_RESIZE_PATH, SMOKE_RESIZE_PATH, SPARE_RESIZE_PATH]
destPaths = [FIRE_DEST_PATH, SMOKE_DEST_PATH, SPARE_DEST_PATH]
numImages = [numFire, numSmoke, numSpare]

numClasses = len(sourcePaths)

resize = False
PCAer = True

def main():

    """
    image = imread(SPARE_SOURCE_PATH + "image" + str(1) + ".jpg")
    length = image.shape[0]
    width = image.shape[1]
    images = np.reshape(image, (1,length*width*3))
    print(images.shape)
    print(image.shape)
    imgplot = plt.imshow(image)
    plt.show()
    """
    if(resize):
        for i in range(0,numClasses):
            resizer(sourcePaths[i], resizePaths[i], numImages[i])
        print("Done Resizing")

    if(PCAer):
        for i in range(0, numClasses):
            images = loadImages(numImages[i], resizePaths[i])
            print("About to PCA")
            #recontructAndPrintImage(images[0])
            #image = PCA2([2],images)
            temp = np.reshape(images[0], (width, length, 3))
            image = kmeans(temp, 32)
            print(image.shape)
            recontructAndPrintImage(image)
        print("Done with PCA")
    return

#Takes a path and resizes all the images in that path
def resizer(sourcePath, destPath, numImages):
    for i in range(1, numImages + 1):
        image = Image.open(sourcePath + "image" + str(i) + ".jpg")
        if image.mode != 'RGB':
            image = image.convert('RGB')
        new_image = image.resize((length,width))
        #recontructAndPrintImage(new_image)
        new_image.save(destPath + "image" + str(i) + ".jpg", "JPEG")
    print("done")
    return

#loads images in dataset
def loadImages(numImages,path):
    images = np.zeros((numImages, 3*length*width), dtype="float")
    for i in range(1,numImages + 1):
        # images[i - 1] = Image.open('../../Data/Faces/face_' + str(i) +  '.png')
        image = imread(path + "image" + str(i) + '.jpg')
        #image = Image.open(path + "image" + str(i) + ".jpg")
        images[i - 1] = np.reshape(image, (1,3*length*width))
    return images

def recontructAndPrintImage(image):
    image = np.reshape(image, (width, length, 3))
    image = image.astype(np.uint8)
    imgplot = plt.imshow(Image.fromarray(image, 'RGB'))
    plt.show()

"""


Below is the code for PCA

"""

def PCA2(KValues, images):
    print("in PCA")
    pca = PCA(n_components=1)
    pca.fit(images)
    image1 = pca.transform(images)
    return image1

def kmeans(images, numclusters):
    print("in KMEANS")
    image = images
    rows = length
    columns = width
    image = image.reshape(rows * columns, 3)
    kMeans = KMeans(n_clusters=numclusters)  # initialize to current k
    kMeans.fit(image)  # fit current image
    compressed_image = np.zeros((rows, columns, 3), dtype=np.uint8)  # to store the final compressed image
    centroids = kMeans.cluster_centers_  # all the centroids
    labels = kMeans.labels_  # which centroid is (row,col) mapped to
    labels = np.reshape(labels, (rows, columns))
    for row in range(0, rows):
        for col in range(0, columns):
            compressed_image[row, col] = centroids[labels[row, col]]  # fill in compressed image by mapping position (row,col) to their label
    img = Image.fromarray(compressed_image, 'RGB')
    return compressed_image

# Calls other functions and runs PCA
def PCA3(KValues, images):
    f = plt.figure()
    error = []
    print("in PCA")
    covMat = covariance(images)
    print("still in PCA")

    # Add first image to chart
    singleImage = images[0]
    temp = np.reshape(singleImage, (width, length, 3))
    temp = temp.astype(np.uint8)
    f.add_subplot(3, 3, 1)
    plt.imshow(Image.fromarray(temp, 'RGB'))
    plt.axis('off')
    plt.title('Original')

    print(images.shape)
    curr = 2 #Keeps track of which image we are plotting in the chart
    for k in KValues:
        print(curr)
        eigenValues, eigenvectors = EigenEverything(covMat, k) # get top k eigenvalues and eigenvectors
        #projection = np.dot(images, eigenvectors.T ) #compress 100 images by projection to k dimenions
        singleProjection = np.dot(singleImage, eigenvectors.T) #compress 1 image by projection to k dimenions
        #reconstructedImages = np.dot(projection, eigenvectors) #decompress 100 images by projection to k dimenions
        reconstructedSingle = np.dot(singleProjection, eigenvectors) #decompress 1 image by projection to k dimenions
        #error.append(RMSE(images, reconstructedImages)) #get error
        #print("k = ", k, " RMSE for 100 images = ", RMSE(images, reconstructedImages))
        #print("k = ", k, " Compression Rate for 100 images = ", ((eigenvectors.nbytes + projection.nbytes)/images.nbytes))

        # add plot
        f.add_subplot(3, 3, curr)
        curr += 1
        temp = np.reshape(singleImage, (width, length, 3))
        temp = temp.astype(np.uint8)
        f.add_subplot(3, 3, 2)
        plt.imshow(Image.fromarray(temp, 'RGB'))
        plt.axis('off')
        plt.title('PCA K =' + str(k))

    #plt.savefig("../Figures/PCA_SingleFace.jpg")
    plt.show()
    #error_plot(error,KValues)
    return

#gets covariance matrix
def covariance(images):
    temp = images.T
    covMat = np.cov(temp)
    return covMat

#gets top k eigenvectors and eigenvalues using covariance matric
def EigenEverything(covMat,k):
    eigenVals, eigenvectors = np.linalg.eigh(covMat)
    eigenVals = np.absolute(eigenVals)
    eigenVals2 = []
    eigenvectors2 = []
    for i in range(0,k):
        index = np.argmax(eigenVals)
        eigenVals2.append(eigenVals[index])
        eigenvectors2.append(eigenvectors[:, index])
        eigenVals[index] = 0
    return (np.array(eigenVals2), np.array(eigenvectors2))


"""


Below is the code for KMeans


"""



imgs = [];
data_dir = "/Users/rushivarora/Documents/Honors Project/Datasets"
# Load images as numpy arrays
print("Starting Stats")
for clas in ["Fire_Resize", "Smoke_Resize", "Spare_Resize"]:
    for fname in os.listdir(data_dir + "/" + clas):
        if(fname == ".DS_Store"):
            continue
        img = Image.open(data_dir + "/" + clas + '/' + fname)
        img_arr = np.array(img) / 255.
        imgs.append(img_arr)
    print("Done with ", clas)

# Conver to a single numpy array
del imgs
temp = np.stack(imgs)
print(temp.shape)
# Extarct each channel
reds, greens, blues = temp[:,:,:,0], temp[:,:,:,1], temp[:,:,:,2]
# Channel-wise means
means = np.mean(reds), np.mean(greens), np.mean(blues)
print("STATS:")
print(means)
# Channel-wise standard deviations
stds = np.std(reds), np.std(greens), np.std(blues)
print(stds)
"""
main()
"""

"""
Steps I have taken:
1) Resize the Images
2) Conduct PCA on them
3) Get the means and standard deviations for all three channels
"""

