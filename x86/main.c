#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define ERROR   -1

void rotbmp1(void *img, void *img_dest, int width);

#pragma pack(push, 1)
typedef struct {
	unsigned short type;
	unsigned long  size;
	unsigned short reserved1;
	unsigned short reserved2;
	unsigned long  offBits;
	unsigned long  bitSize;
	long  width;
	long  height;
	short planes;
	short bitPerPixel;
	unsigned long  compression;
	unsigned long  sizeImage;
	long xPelsPerMeter;
	long yPelsPerMeter;
	unsigned long  biClrUsed;
	unsigned long  biClrImportant;
	unsigned long  RGBQuad_0;
	unsigned long  RGBQuad_1;
} bmpHeader;
#pragma pack(pop)

int saveImage(const bmpHeader bmpHead, unsigned char* bmpFileData, int sizeOfFileData) {
	FILE* bmpFile;
	if ((bmpFile = fopen("out.bmp", "wb")) == 0)
        return ERROR;

	if (fwrite(&bmpHead, sizeof(bmpHeader), 1, bmpFile) != 1) {
		fclose(bmpFile);
		return ERROR;
	}

    if (fwrite(bmpFileData, sizeOfFileData, 1, bmpFile) != 1) {
		fclose(bmpFile);
		return ERROR;
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

    printf("Input image:\n");
    printf("Image width:\t\t%d\n", imageWidth);
    printf("Image height:\t\t%d\n", imageHeight);
    printf("BPP:\t\t\t%d\n", bmpHead.bitPerPixel);

    int padding = 0;
    while ((imageWidth + padding) % 32 != 0)
        padding++;
    int actualImageWidth = imageWidth + padding;
    int byteImageWidth = actualImageWidth / 8;

    unsigned long imageDataSize = sizeof(unsigned char) * imageHeight * actualImageWidth / 8;
    printf("Bitmap size:\t\t%ld\n", imageDataSize);

    unsigned char *data = (unsigned char*) malloc(imageDataSize);
    fread(data, sizeof(unsigned char), imageDataSize, imgFile);

    unsigned char *data_empty = (unsigned char*) malloc(imageDataSize);
    fread(data_empty, sizeof(unsigned char), imageDataSize, imgFile);

    rotbmp1(data, data_empty, imageWidth);

    if (!saveImage(bmpHead, data, imageDataSize))
        printf("Image saved successfully.\n");
    else
        printf("Saving file failed.\n");

    fclose(imgFile);
    return data;
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