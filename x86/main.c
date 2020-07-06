#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void rotbmp1(void *img, int width);
//int rotbmp1(void *img, void *img_dest, int width);
#pragma pack(push, 1)
typedef struct {
	unsigned short type;
	unsigned long  size;
	unsigned short reserved1;
	unsigned short reserved2;
	unsigned long  offset;
	unsigned long  dibHeaderSize;
	long  width;
	long  height;
	short planes;
	short bitPerPixel;
	unsigned long  compression;
	unsigned long  sizeImage;
	long xPelsPerMeter;
	long yPelsPerMeter;
    long palette;
    long impColors;
	unsigned long  RGBQuad_0;
	unsigned long  RGBQuad_1;
} bmpHeader;
#pragma pack(pop)

int saveImage(const bmpHeader bmpHead, unsigned char* bmpFileData, int sizeOfFileData) {
	FILE* bmpFile;
	if ((bmpFile = fopen("out.bmp", "wb")) == 0)
        return -1;

	if (fwrite(&bmpHead, sizeof(bmpHeader), 1, bmpFile) != 1) {
		fclose(bmpFile);
		return -1;
	}

    if (fwrite(bmpFileData, sizeOfFileData, 1, bmpFile) != 1) {
		fclose(bmpFile);
		return -1;
	}

	fclose(bmpFile);
	return 0;
}

unsigned char *processImage(char* filename) {
    bmpHeader bmpHead;
    FILE *imgFile = fopen(filename, "rb");
    if (!imgFile)
        return NULL;

    fread((void *) &bmpHead, sizeof(bmpHead), 1, imgFile);

    int imageWidth = bmpHead.width;
    int imageHeight = bmpHead.height;
    int bpp = bmpHead.bitPerPixel;

    printf("Input image:\n");
    printf("Image width:\t\t%d\n", imageWidth);
    printf("Image height:\t\t%d\n", imageHeight);
    printf("BPP:\t\t\t%d\n", bpp);

    if (imageWidth != imageHeight)
        printf("Image is not square.\n");

    if (bpp != 1)
        printf("Image is not 1bpp.\n");

    int padding = 0;
    while ((imageWidth + padding) % 32 != 0)
        padding++;
    int actualImageWidth = imageWidth + padding;
    int byteImageWidth = actualImageWidth / 8;

    unsigned long imageDataSize = sizeof(unsigned char) * imageHeight * actualImageWidth / 8;
    printf("Bitmap size:\t\t%ld\n", imageDataSize);

    unsigned char *data = (unsigned char*) malloc(imageDataSize);
    fread(data, sizeof(unsigned char), imageDataSize, imgFile);

    unsigned char *data_dest = (unsigned char*) malloc(imageDataSize);
    fread(data_dest, sizeof(unsigned char), imageDataSize, imgFile);

    rotbmp1(data, imageWidth);

    if (!saveImage(bmpHead, data_dest, imageDataSize))
        printf("Image saved successfully.\n");
    else
        printf("Saving file failed.\n");

    fclose(imgFile);
    return data_dest;
}

int main (int argc, char* argv[]) {
	if (argc != 2)
        printf("Wrong number of arguments.\n");
    else {
        char *res = processImage(argv[1]);
        if (!res)
            printf("Saving file failed.\n");
        else
            free(res);
    }
    return 0;
}