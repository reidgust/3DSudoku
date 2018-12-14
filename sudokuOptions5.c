#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
typedef enum { false, true } bool;

unsigned short validRows[120];
char validRowsChars[120][5];
unsigned char workingSet[25] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int answers = 0;
static FILE* f;

void makeValidRows() {
    int i = 0;
    unsigned short row = 0;
    for (int j=0; j < 5; j++) {
        for (int k=0; k < 5; k++) {
            if (j==k) continue;
            for (int l=0; l < 5; l++) {
                if (j==l || k==l) continue;
                for (int m=0; m < 5; m++) {
                    if (j==m || k==m || l==m) continue;
                    for (int n=0; n < 5; n++){
                        if (j==n || k==n || l==n || m==n) continue;
                        row = 0;
                        row = ((j << 12) & 0x7000) | ((k << 9) & 0xe00) | ((l << 6) & 0x1c0) | ((m << 3) & 0x38) | (n & 0x7);
                        for (int p=0; p<5; p++) {
                            switch ((row >> (3 * p)) & 0x7){
                                case 0:
                                    validRowsChars[i][p] = 'R';
                                    break;
                                case 1:
                                    validRowsChars[i][p] = 'G';
                                    break;
                                case 2:
                                    validRowsChars[i][p] = 'B';
                                    break;
                                case 3:
                                    validRowsChars[i][p] = 'Y';
                                    break;
                                case 4:
                                    validRowsChars[i][p] = 'P';
                            }
                        }
                        validRows[i++] = row;
                    }
                }
            }
        }
    }
}

void printRow(int i){
    for (int j = 0; j < 5; j++) fprintf(f,"%c", validRowsChars[i][4-j]);
}

void printValidRows() {
    fprintf(f,"Valid Rows\n[");
    for (int i=0; i < 120; i++) {
        fprintf(f, "%x",validRows[i]);
        if (i != 119) fprintf(f,",");
    }
    fprintf(f,"]\n\n");
}

void printValidRowsVisual() {
    fprintf(f,"Valid Rows\n");
    for (int i=0; i < 120; i++) {
        fprintf(f, "%i   ",i);
        printRow(i);
    }
    fprintf(f,"\n");
}

void printAnswerVisual() {
    for (int i = 0; i < 25; i++ ) {
        printRow(workingSet[i]);
        if (i % 5 == 4) fprintf(f,"\n");
    }
    fprintf(f,"\n\n\n");
}

void printAnswer() {
    fprintf(f,"[");
    for (int i=0; i < 25; i++) {
        fprintf(f,"%x",validRows[workingSet[i]]);
        if (i != 24) fprintf(f,",");
    }
    fprintf(f,"],");
}

int newRowGood(int currentIndex, int proposedRow) {
    // Look on columns on same face.
    for (int j = (currentIndex/5)*5; j < currentIndex; j++) {
        unsigned int rowJ = workingSet[j];
        if ((validRowsChars[proposedRow][0] == validRowsChars[rowJ][0]) ||
            (validRowsChars[proposedRow][1] == validRowsChars[rowJ][1]) ||
            (validRowsChars[proposedRow][2] == validRowsChars[rowJ][2]) ||
            (validRowsChars[proposedRow][3] == validRowsChars[rowJ][3]) ||
            (validRowsChars[proposedRow][4] == validRowsChars[rowJ][4])) {
            return 0;
        }
    }
    // Look at columns of different depths.
    for (int j = currentIndex%5; j < currentIndex; j=j+5) {
        unsigned int rowJ = workingSet[j];
        if ((validRowsChars[proposedRow][0] == validRowsChars[rowJ][0]) ||
            (validRowsChars[proposedRow][1] == validRowsChars[rowJ][1]) ||
            (validRowsChars[proposedRow][2] == validRowsChars[rowJ][2]) ||
            (validRowsChars[proposedRow][3] == validRowsChars[rowJ][3]) ||
            (validRowsChars[proposedRow][4] == validRowsChars[rowJ][4])) {
            return 0;
        }
    }
    return 1;
}

void assignRow(int i) {
    for (int j = 0; j < 120; j++){
        if(newRowGood(i,j) == 1) {
            workingSet[i] = j;
            if (i < 24) {
                if (rand() % 10 > 2) assignRow(i+1);
            } else {
                printAnswer();
            }
        }
        if (i==1) printf("%i\n",j);
    }
}

void confirmValidRowsAreValid() {
    for (int i = 0; i < 120; i++) {
        bool colors[5] = {false,false,false,false,false};
        for (int j = 0; j < 5; j++){
            switch (validRowsChars[i][j]){
            case 'R':
                colors[0] = true;
                break;
            case 'G':
                colors[1] = true;
                break;
            case 'B':
                colors[2] = true;
                break;
            case 'Y':
                colors[3] = true;
                break;
            case 'P':
                colors[4] = true;
                break;
            }
        }
        if (colors[0] && colors[1] && colors[2] && colors[3] && colors[4]) {
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
    f = fopen("Answers5.txt", "w");
    if (f == NULL)
    {
        printf("Error opening file!\n");
        exit(1);
    }
    makeValidRows();
    time_t t;
    srand((unsigned) time(&t));
    fprintf(f,"[");
    workingSet[0] = 0;
    assignRow(1);
    fclose(f);
    return 0;
}


