#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>


    /*
    W source - tylko pierwszy bit w bajcie, przejśćie do kolejnego bajtu:
        Liczenie nowej pozycji - i sprawdzenie czy nie wychodzi poza height.
        Jeśli przechodzi poza height: przesuwamy cox++, coy = width - 1.
        Jesli nie wychodzi poza height: coy++
    W destination przechodzenie bajt po bajcie. Po przejściu 8 bitow w source sklejoncały bajt.
    Swap tego bajtu z bajtem w destination.
    W destination:
        Zaczynamy w lewym górnym rogu.
        Po swapie przejście do kolejnego bajtu - sprawdzenie czy nie poza zakresem (width).
        Jeśli poza zakresem: przejście do kolejnego wiersza: cox = 0, coy++;
    */

int main(int argc, char* argv[]) {
    int N = 64;
    int width = 8;
    int data[N] = {1, 2, 3, 4, 5, 6, 7, 8,
                    9, 10, 11, 12, 13, 14, 15, 16,
                    17, 18, 19, 20, 21, 22, 23, 24,
                    25, 26, 27, 28, 29, 30, 31, 32,
                    33, 34, 35, 36, 37, 38, 39, 40,
                    41, 42, 43, 44, 45, 46, 47, 48,
                    49, 50, 51, 52, 53, 54, 55, 56,
                    57, 58, 59, 60, 61, 62, 63, 64};

    int rot[N] = {0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0};

    int cox_s = 0, cox_d = 0, coy_s = 0, coy_d = 0;
    int source = 0, dest = 0;
    int index = 0;
    int byte = 0;
    int bit_number = 0;
    int shift = 7;

    // Source - lewy dolny róg.
    cox_s = 0;
    coy_s = width - 1;
    printf("Init\t cox_s %d, coy_s %d, index source %d\n", cox_s, coy_s, source = cox_s + coy_s * width);

    // Destination - lewy górny róg.
    cox_d = 0;
    coy_d = 0;

    // data[] binarnie:
    int bits[N*8];
    for(int j = 0; j < N;j++) {
        for(int i = 0; i < 8;++i){
            bits[8*j+i] = data[j] & (1 << i) ? 1 : 0;
            printf("%d", bits[8*j+i]);
        }
        printf("    ");
    }
    printf("\n\n");


    // Source obsługiwane w środku j-fora

    for (int i = 0; i < width; i++) {
        //coy = i + 1;

        for (int j = 0; j < width; j++) {
            // Calculating position

            // Find source.

            for (int k = 0; k < 8; k++) {
                source = cox_s + coy_s * width;
                printf("Source %d, %d, bit number %d\n", source, data[source], bit_number);
                int bit = (data[source] & (1 << bit_number));   // Taking 1st bit.
                printf("bit %d\n", bit);
                coy_s--;
                bit << shift;
                printf("bit_shift %d\n", bit);
                shift--;
                // Forming a byte.
                byte += bit;
            }

            printf("byte %d\n\n", byte);
            coy_s = width - 1;
            bit_number++;
            shift = 7;

            // Calculate destination index.
            dest = cox_d + coy_d * width;

            // Swap created byte with destination.
            rot[dest] = byte;
            byte = 0;

            cox_d++;

            if (bit_number > 7)
                bit_number = 0;
        }
        coy_d++;
        cox_d = 0;


        cox_s++;
        coy_s = width - 1;

        bit_number = 0;
    }

    // Wyświetl tablicę w postaci binarnej.
    printf("\n\n");
    int bits_rot[N*8];
    for(int j = 0; j < N;j++){
        for(int i = 0; i < 8;++i){
            bits_rot[8*j+i] = rot[j] & (1 << i) ? 1 : 0;
            printf("%d", bits_rot[8*j+i]);
        }
        printf("    ");
    }
    printf("\n");

    return 0;
}
