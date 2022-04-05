//
//  packet_handler.cpp
//  MLKit Final Project
//
//  Created by CLWang on 2021/5/12.
//  Copyright © 2021 AppCoda. All rights reserved.
//

#include "packet_handler.hpp"

extern "C" char* readdata(std::string data){
    char* data2 = new char [10000];
    for (int i=0;i<sizeof(data);i++){
        if (data[i]=='d'&&data[i+1]=='e'&&data[i+2]=='s'&&data[i+3]=='c'){
            if(data[i+14]=='"'){
                i+=15;
                int j=0;
                while(data[i]!='"'){
                    data2[j]=data[i];
                    i++;j++;
                }
                break;
            }
        }
    }
    return data2;
}
