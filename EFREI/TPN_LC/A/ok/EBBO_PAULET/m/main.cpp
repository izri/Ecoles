#include <iostream>
#include <algorithm>
#include "fonction.h"

using namespace std;



int main()
{
    cout << "Langages et Compilation" << endl;

    grammaire Grammaire;
    Grammaire.show();
	Grammaire.creation_automate();


	int end;
	cin >> end;
    return 0;
}