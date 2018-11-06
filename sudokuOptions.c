#include <stdlib.h>
#include <stdio.h>
#include <string.h>

unsigned char validRows[24] = {
    0x1b/*RGBY*/,0x1e/*RGYB*/,0x27/*RBGY*/,0x2d/*RBYG*/,0x36/*RYGB*/,
    0x39/*RYBG*/,0x4b/*GRBY*/,0x4e/*GRYB*/,0x63/*GBRY*/,0x6c/*GBYR*/,
    0x72/*GYRB*/,0x78/*GYBR*/,0x87/*BRGY*/,0x8d/*BRYG*/,0x93/*BGRY*/,
    0x9c/*BGYR*/,0xb1/*BYRG*/,0xb4/*BYGR*/,0xc6/*YRGB*/,0xc9/*YRBG*/,
    0xd2/*YGRB*/,0xd8/*YGBR*/,0xe1/*YBRG*/,0xe4/*YBGR*/
};

unsigned char workingSet[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

static FILE* f;

void printAnswerVisual() {
    for (int i = 0; i < 64; i++ ) {
        switch ((workingSet[i/4] >> (6 - (( i % 4 ) * 2))) & 0x3) {
            case 0: fprintf(f,"R");
                break;
            case 1: fprintf(f,"G");
                break;
            case 2: fprintf(f,"B");
                break;
            case 3: fprintf(f,"Y");
        }
        if ( i % 4 == 3 ) fprintf(f,"\n");
        if (i % 16 == 15) fprintf(f,"\n");
    }
    fprintf(f,"\n\n\n");
}

void printAnswer() {
    fprintf(f,"\"");
    unsigned int res = 0;
    for (int i=0; i < 16; i++) {
        unsigned char actualVal = workingSet[i];
        fprintf(f,"%02X",actualVal & 0x3F);
    }
    fprintf(f,"\",");
}

int newRowGood(int i, unsigned char newRow) {
    for (int j = (i/4)*4; j < i; j++) {
        unsigned char rowJ = workingSet[j];
        if ((( newRow       & 0x3) == ( rowJ       & 0x3)) ||
            (((newRow >> 2) & 0x3) == ((rowJ >> 2) & 0x3)) ||
            (((newRow >> 4) & 0x3) == ((rowJ >> 4) & 0x3)) ||
            (((newRow >> 6) & 0x3) == ((rowJ >> 6) & 0x3))) {
            return 0;
        }
    }
    for (int j = i%4; j < i; j=j+4) {
        unsigned char rowJ = workingSet[j];
        if ((( newRow       & 0x3) == ( rowJ       & 0x3)) ||
            (((newRow >> 2) & 0x3) == ((rowJ >> 2) & 0x3)) ||
            (((newRow >> 4) & 0x3) == ((rowJ >> 4) & 0x3)) ||
            (((newRow >> 6) & 0x3) == ((rowJ >> 6) & 0x3))) {
            return 0;
        }
    }
    return 1;
}

void assignRow(int i) {
    for (int j = 0; j < 24; j++){
        unsigned char newRow = validRows[j];
        if(newRowGood(i,newRow) == 1) {
            workingSet[i] = newRow;
            if (i < 15) {
                assignRow(i+1);
            } else {
                printAnswer();
            }
        }
    }
}

void confirmValidRowsAreValid() {
    for (int i = 0; i < 24; i++) {
        if (((validRows[i] & 0x3) ^ ((validRows[i] >> 2) & 0x3) ^
             ((validRows[i] >> 4) & 0x3) ^ ((validRows[i] >> 6) & 0x3)) == 0) {
            printf("YAY!");
        } else {
            printf("OH NO!: 0x%x",validRows[i]);
        }
        printf("\n");
    }
}

/*
 * Initialize a new cache set with the given associativity and block
 * size.
 */
int main() {
    f = fopen("Answers.txt", "w");
    if (f == NULL)
    {
        printf("Error opening file!\n");
        exit(1);
    }

    workingSet[0] = validRows[0];
    fprintf(f,"[");
    assignRow(1);
    fclose(f);
    
    return 0;
}


