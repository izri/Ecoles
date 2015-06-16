clc;
clear all;

AvarianteStab=[1]; % 3 4]; %la 2 est assez compliqu�
BvarianteRB=[1];
CvariantePuis=[2];
rbListe=[6 15 25 50 75 100];
nbreSimul= 10; %30
allFileDat='*.dat';
allFileTxt='*.txt';
Nstabilisation= 50; %100
%rayon
%charge
tauxErr=1.96; 
valeur=1000;
Vv=7;
%matrice=zeros(V, valeur);   
for iPuis=1:length(CvariantePuis)
    clc;
    varianteALGO=CvariantePuis(iPuis);
    for jRB=1:length(BvarianteRB)
        varianteChooseRB=BvarianteRB(jRB);
      for kStab=1:length(AvarianteStab)  
          varianteStab=AvarianteStab(kStab);
           for rRB=1:length(rbListe)
               %creer repertoire save
               N=rbListe(rRB);
               NEWDIR= strcat('Puis', num2str(varianteALGO), '-ChooseRB', num2str(varianteChooseRB), '-Stab', num2str(varianteStab),'-RB', num2str(N));
               mkdir(NEWDIR);
               %cd(NEWDIR);
               %nbITER=[];
           
                  for iyy=1:Vv
                     matrice{iyy}.val=[];
                  end
               for nS=1:nbreSimul
                   %modifier chacune des variables 
            
                   %lancer la simul
                  % ProgInterferenceVariante3
               
                   ProgInterferenceLTEq
                %   nbITER=[nbITER, COUNT];
                %il faut juste v�rifier avant que la dimension de matrice
                %et celle de gainGlobal est pareil
         
                for iy=1:Vv
                   [nnnnn, lllll]= size(gainGlobal(iy,:));
                   [n1, l1]=size(matrice{iy}.val);
                if(l1~= lllll)
                    %faut d'abord compl�ter avant de faire la fusion
                    if lllll >l1
                       rrrr=lllll-l1;
                       compl=zeros(nS,rrrr);
                       newGGGG=[];
                       newGGGG=[matrice{iy}.val, compl];
                       matrice{iy}.val=[newGGGG;  gainGlobal(iy,:)];
                    else
                       rrrr=l1-lllll; 
                       compl=zeros(nS,rrrr);
                       
                       newGGGG=[];
                       newGGGG=[gainGlobal(iy,:), compl];
                       matrice{iy}.val=[matrice{iy}.val;  newGGGG];
       
                    end

                else
       
                  matrice{iy}.val=[matrice{iy}.val;  gainGlobal(iy,:)];
               % matrice=[matrice,  gainGlobal];
               % matrice=matrice+gainGlobal;
                end      
                    
                    
               
                end      
                Outputfiilleeele= strcat('resultsSimul',num2str(nS), '.mat');
                save(Outputfiilleeele, 'gainGlobal');   
%               %creer repertoire save portant le n� de la simul
                NEWD=strcat('Simul', num2str(nS));
                mkdir(NEWD);
         
                succ=movefile(allFileDat, NEWD, 'f');
                suuu=movefile(allFileTxt, NEWD, 'f');
                     suuuuC=movefile(Outputfiilleeele, NEWD, 'f');
                
                if ((succ==1) && (suuu==1))
                 

                      succ2=movefile(NEWD, NEWDIR, 'f');
%                   %  suuu2=movefile(allFileTxt, NEWD, 'f');
%                     
                    if (succ2==0)  
                        fprintf('ERREUUUUUUUUR de copie avec succ2 \n');
                        break; 
                    end     
                else
                    fprintf('ERREUUUUUUUUR de copie avec succ  ou suuu \n');
                    break;
                end
                
                
                
                %copier tous les fichiers dans le r�pertoire qu'il faut 
%                  cd(NEWDIR);
%                  cd(NEWD);
%                  cd ..
%                  cd ..
               end
 
          for uuuu=1:Vv
                 [nbL, nbC]=size(matrice{uuuu}.val);
               vect=zeros(1,nbC);  
            for ccccc=1:nbC
                vect(ccccc)=ccccc;
            end
                  gainMMM=mean(matrice{uuuu}.val);
                  ecarttt=std(matrice{uuuu}.val);
                  ajustementIntervaCOnf=(tauxErr*ecarttt)/sqrt(nbreSimul);
                  truc=[];
                  truc=[truc; vect];
                  truc=[truc; gainMMM]; %moyenne pr chaque cellule
                  truc=[truc; ajustementIntervaCOnf]; %pr ajuster l'intervalle de confiance
                  filePPP=strcat('gainMoyenTRace',num2str(uuuu), '.mat');
            	  save(filePPP,'truc');
                  sucffc2=movefile(filePPP, NEWDIR, 'f');  
             % end
          end    
          
          
%            valeur=max(nbITER);
%            matrice=zeros(V, valeur);     
%            for iii=1:nbreSimul
%             Outputfiilleeele= strcat('resultsSimul',num2str(iii), '.mat');
%             mattt=load(Outputfiilleeele);
%             
%            end
               
           end
      end
    end
end