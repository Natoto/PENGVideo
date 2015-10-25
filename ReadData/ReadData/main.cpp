//
//  main.cpp
//  ReadData
//
//  Created by BooB on 15/10/25.
//  Copyright (c) 2015年 BooB. All rights reserved.
//

#include <iostream>
#include <fstream>
using namespace std;
struct student
{
    string name;
    int num;
    int age;
    char sex;
    
};
int readstudent();
void writestudent();
//length 28 : 0000001C
//0x1002 : 00001002
//"nonato" : 00066E6F6E61746F
//"nonatopassword" : 000E6E6F6E61746F70617373776F7264
struct authstruct
{
    int length;
    int protocol;
    string username;
    string password;
};

int main( )
{
//    readstudent();
    authstruct auth = {28,0x1002,"nonato","nonatopassword"};
 
    
    return 0;
}

//void sendPacket()
//{
//    BOOL fin = YES;
//    int payloadLen = 12;
//    int opcode = 0x02; // binary
//    int len1 = 127;
//    int mask = 0;
////     *header = [NSMutableData dataWithLength:10];
//    unsigned char *data = (unsigned char *)[header bytes];
//    data[0] = (fin ? 0x80 : 0x00) | (opcode & 0x0f);
//    data[1] = (mask ? 0x80 : 0x00) | (len1 & 0x7f);
//    data[2] = 0;
//    data[3] = 0;
//    data[4] = 0;
//    data[5] = 0;
//    data[6] = (payloadLen>>24) & 0xFF;
//    data[7] = (payloadLen>>16) & 0xFF;
//    data[8] = (payloadLen>> 8) & 0xFF;
//    data[9] = (payloadLen>> 0) & 0xFF;
//    [self enqueueData:header];
//    
//    NSMutableData *payload = [NSMutableData dataWithLength:payloadLen];
//    [self enqueueData:payload];
//}


void writestudent()
{
    student stud[3]={"Li",1001,18,'f',"Fun",1002,19,'m',"Wang",1004,17,'f'};
    ofstream outfile("stud.dat",ios::binary);
    if(!outfile)
    {
        cerr<<"open error!"<<endl;
        abort( );//退出程序
    }
    for(int i=0;i<3;i++)
        outfile.write((char*)&stud[i],sizeof(stud[i]));
    outfile.close( );
}

int readstudent( )
{
    student stud[3];
    int i;
    ifstream infile("stud.dat",ios::binary);
    if(!infile)
    {
        cerr<<"open error!"<<endl;
        abort( );
    }
    for(i=0;i<3;i++)
        infile.read((char*)&stud[i],sizeof(stud[i]));
    infile.close( );
    for(i=0;i<3;i++)
    {
        cout<<"NO."<<i+1<<endl;
        cout<<"name:"<<stud[i].name<<endl;
        cout<<"num:"<<stud[i].num<<endl;;
        cout<<"age:"<<stud[i].age<<endl;
        cout<<"sex:"<<stud[i].sex<<endl<<endl;
    }
    return 0;
}
