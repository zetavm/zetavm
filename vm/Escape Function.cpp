#include <iostream>

using namespace std;

string escape(string str){

	int n=str.length();
	int i=0;
	string res;

	while(i<n){
		if((str[i]>='a' && str[i]<='z') || (str[i]>='A' && str[i]<='Z')){
			res=res+str[i];
		}
		i++;
	}
	return res;
}

int main(){
	
	cout<<escape("*$# Programmer #$*");
	return 0;
}
