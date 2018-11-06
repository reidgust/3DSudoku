#include <stdlib.h>
#include <stdio.h>
#include <string.h>

unsigned char validRows[24] ={0x1b,0x1e,0x27,0x2d,0x36,0x39,0x4b,0x4e,0x63,0x6c,0x72,0x78,
    0x87,0x8d,0x93,0x9c,0xb1,0xb4,0xc6,0xc9,0xd2,0xd8,0xe1,0xe4};

unsigned char workingSet[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

unsigned char count = 0;

static FILE* f;

void printface() {
    for (int i = 0; i < 16; i++ ) {
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
        if ( i == 15 ) fprintf(f,"\n");
    }
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
    return 1;
}

void assignRow(int i) {
    for (int j = 0; j < 24; j++){
        unsigned char newRow = validRows[j];
        if(newRowGood(i,newRow) == 1) {
            workingSet[i] = newRow;
            if (i < 3) {
                assignRow(i+1);
            } else {
                printface();
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
    assignRow(1);
    fclose(f);
    
    return 0;
}


