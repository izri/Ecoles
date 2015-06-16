#include <iostream>
#include <string>
#include <windows.h>
#include <stack>
#include <stdlib.h>
#include <stdio.h>

using namespace std;


#define MAXSGram   100   //�ķ��������
#define MAXSItems  100  //��Ŀ���������
#define MAXSItem   100  //һ����Ŀ�������ʽ����





/*
����ķ�ʽ�ӵĽṹ��
*/
struct GrammarFormulas
{
	string left;
	string right;
};



struct  SKIP
{
	char  skipStr;   //�����ַ�
	int   ToState;   //��ת����״̬
};

struct  ITEM
{
	int n;                //ʽ�Ӽ�����Ŀ
	string  I[MAXSItem];  //ʽ�Ӽ���
	string  ForwardSet[MAXSItem];   //��ǰ������

	SKIP    skip[MAXSItems]; //��ת״̬
	int     nSkipNum;  //��ת״̬��Ŀ
	ITEM()
	{
		n = 0;
		nSkipNum = 0;
	}
};

/*------��������-----------------------------------*/
int   IsIncludeItems(ITEM item, ITEM *items);
int   IsIncludeItem(string s, ITEM item);
int   IsIncludeStr(char c, string p);

void  PrintGram(GrammarFormulas *p);
void  PrintItems(ITEM *item);
void  PrintAnalyTable();

/*--------�ķ����봦������-------------------------*/
char  GetNewNon_Ter();
void  StrToGram(GrammarFormulas *p, string str);
void  GetGrammer(GrammarFormulas *grams);
int   GetGramFromFile(GrammarFormulas *grams, char *FileName);

/*-------��ǰ��������������---------------------------------*/
void    GetFirstSet(GrammarFormulas *p, string FirsetSet[]);
string  GetForwardSet(string expression, string OldForwardSet, GrammarFormulas *p);

/*-------��Ŀ���崦������------------------------------*/
int   CLOSURE(ITEM  &item, GrammarFormulas  *p);
ITEM  Go(ITEM  item, char  X, GrammarFormulas  *p);
int   GetItem(ITEM  *items, GrammarFormulas  *p);

/*---------��ȡ������-----------------------------*/
void GetAnalyTable(ITEM  *items,GrammarFormulas  *p);


/*---------LR1����----------------------------------*/
void  LR1Analy(GrammarFormulas  *p);