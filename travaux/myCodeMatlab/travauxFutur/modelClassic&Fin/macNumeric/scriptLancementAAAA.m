clc;
clear all;

capTrame=[669]; % 710 690 650]; 
%669==> 15 RBs
nbreTrame=[10 50 100 200 500 1000]; % 50 100 200 1]; % 180 9 45]; %10 20 30 50];
tailleBuffer=[1000]; % 1500 2000 500 2500]; % 50 100 200];
nbreSimul= 10; %30;
%refaire avec 30 simuls pr am�liorer l'intervalle de confiance
fileDat='arrive*.dat';
filePoisson='PoissonAr*.dat';
file='distribFi*.dat';
file1='taillesTrames.dat';
file2='indic*.dat';
file3='instantsGener.dat';
fichier='results.dat';
fichhhh='results-Ca*.dat';
testttt='NbreTrameMax*';
fichierMoye='resultsAVG.dat';
stateQueue='etatQueue*.dat';
tauxErr=1.96; %intervalle de confiance de 95%
for iPuis=1:length(nbreTrame)
      clc;
      T_max=nbreTrame(iPuis);
      NEWDiii=strcat('R', num2str(T_max));
      mkdir(NEWDiii);   
      for kStab=1:length(capTrame)  
          C=capTrame(kStab);
          fichTMP=strcat('results-Cap', num2str(C),'-nbreTRame', num2str(T_max), '.dat');
           for rRB=1:length(tailleBuffer)
               %creer repertoire save
               Buffer=tailleBuffer(rRB);
               fileBuf=strcat('results-Buuff', num2str(Buffer), '.dat');
               NEWDIR= strcat('NbreTrameMax', num2str(T_max),  '-Capacity', num2str(C), '-Buffer', num2str(Buffer));
               mkdir(NEWDIR);
               %cd(NEWDIR);
               cumulSim1=[];
               cumulSim2=[];
               
               taiileFrame=[];
               vecteurTrame=zeros(nbreSimul,T_max);
               prob1=zeros(nbreSimul, Buffer+1);
               prob2=zeros(nbreSimul, Buffer+1);
               for nS=1:nbreSimul
                   %modifier chacune des variables   
                   %lancer la simul
           
               analyseMacNumSimplOkii
               cumulSim2=[cumulSim2, AttenteFile{2}];
               cumulSim1=[cumulSim1, AttenteFile{1}];
               %PI{ll}.dist
               
               taiileFrame=[taiileFrame, TailleTrame];
               for ii=1:T_max
                  vecteurTrame(nS, ii)=vecteurTrame(nS, ii)+ TailleTrame(ii);
               end
%               %creer repertoire save portant le n� de la simul
                NEWD=strcat('Simul', num2str(nS));
                mkdir(NEWD); 
                succ=movefile(fileDat, NEWD, 'f');
                suuu=movefile(filePoisson, NEWD, 'f');
                suuu2=movefile(file, NEWD, 'f');
                suuu1=movefile(file1, NEWD, 'f');
                suuu4=movefile(file2, NEWD, 'f');
                suuu3=movefile(file3, NEWD, 'f');
                ssssss=movefile(stateQueue, NEWD, 'f');
                
                if ((succ==1) && (suuu==1) && (suuu1==1) && (suuu2==1) && (suuu3==1) && (suuu4==1) )
                 

                      succ2=movefile(NEWD, NEWDIR, 'f');
%                   %  suuu2=movefile(allFileTxt, NEWD, 'f');
                      sss=copyfile(fichier, NEWDIR, 'f');
                    if (succ2==0)  
                        fprintf('ERREUUUUUUUUR de copie avec succ2 \n');
                        break; 
                    end     
                else
                    if (succ==0)
                    fprintf('ERREUUUUUUUUR de copie avec succ \n');  
                       break;
                    else
                            if (suuu==0)
                               fprintf('ERREUUUUUUUUR de copie avec suuu \n');        
                             break;
                            else
                               if (suuu1==0)
                               fprintf('ERREUUUUUUUUR de copie avec suuu1 \n');        
                                break;
                               else
                                if (suuu2==0)
                               fprintf('ERREUUUUUUUUR de copie avec suuu2 \n');        
                             break;
                                else
                             if (suuu3==0)
                               fprintf('ERREUUUUUUUUR de copie avec suuu3 \n');        
                              break;
                             else
                                if (suuu4==0)
                               fprintf('ERREUUUUUUUUR de copie avec suuu4 \n');        
                              break;
                                
                            end
                            end   
                            end
                         end 
                      end
                 
                    end
                end
        
                %copier tous les fichiers dans le r�pertoire qu'il faut 
%                  cd(NEWDIR);
%                  cd(NEWD);
%                  cd ..
%                  cd ..
                for inddd=1:(Buffer+1)
                    prob1(nS,inddd)=prob1(nS,inddd)+ PI{1}.dist(inddd);
                    prob2(nS,inddd)=prob2(nS,inddd) + PI{2}.dist(inddd);
                end
                
               end
               
             for inddd=1:(Buffer+1)
                prob1AVG(inddd)=mean(prob1(1:nbreSimul,inddd)); %+ PI{1}.dist(inddd);
                ecartTypeB1(inddd)=std(prob1(1:nbreSimul,inddd));
                ajustBuf1(inddd)=(tauxErr*ecartTypeB1(inddd))/sqrt(nbreSimul);  %prob1(inddd)
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prob2AVG(inddd)=mean(prob2(1:nbreSimul,inddd));% + PI{2}.dist(inddd);
                ecartTypeB2(inddd)=std(prob2(1:nbreSimul,inddd));
                ajustBuf2(inddd)=(tauxErr*ecartTypeB2(inddd))/sqrt(nbreSimul); %prob2(inddd)
             end      
            ortieFile= strcat('distribQUEUE',num2str(Buffer),'-',num2str(T_max),'-',num2str(C) , '.dat');
            fiAVGdistr = fopen(ortieFile, 'w');  %wt  
            
        %  aaaa=sum(prob1AVG)
        %  bbbb= sum(prob2AVG)
          
           for indddeee=1:(Buffer+1)      
               fprintf(fiAVGdistr, '%g \t %g \t %g  \t %g   \t %g  \n', indddeee, prob1AVG(indddeee),  ajustBuf1(indddeee), prob2AVG(indddeee), ajustBuf2(indddeee) );
           end
           fclose(fiAVGdistr);
           
            
            s3=movefile(ortieFile, NEWDIR, 'f');
            tmpFichier='distribQUEUE.dat';
            tttttttt=copyfile(ortieFile, tmpFichier, 'f');
            s4=movefile(tmpFichier, NEWDIR, 'f');
            for uu=1:T_max
                vecteurTrameAVG(uu)=mean(vecteurTrame(1:nbreSimul,uu)); %/T_max; %+ TailleTrame(ii);
                ecartTypAtteTT(uu)= std(vecteurTrame(1:nbreSimul,uu));
                ajustIntervTT(uu)=(tauxErr*ecartTypAtteTT(uu))/sqrt(nbreSimul*T_max); %vecteurTrameAVG(uu));
            end  
            Outputfiilleeele= strcat('resultsAVGtrame',num2str(Buffer),'-',num2str(T_max),'-',num2str(C) , '.mat');
            save(Outputfiilleeele, 'vecteurTrameAVG');
            s2=copyfile(Outputfiilleeele, NEWDIR, 'f');
            Outputfiillle= strcat('resultsAVG.dat'); %pr les trames
            fiAVG = fopen(Outputfiillle, 'w');  %wt           
            moyenAttente2=mean(cumulSim2);    
            moyenAttente1=mean(cumulSim1);  
            moyenTrame=mean(taiileFrame);
                %%%%%%%%
            ecartTypTR= std(taiileFrame);
            ajustIntervTram=(tauxErr*ecartTypTR)/sqrt(nbreSimul*T_max); %moyenTrame);
                %%%%%%%%
            ecartTypAtteF1= std(cumulSim1);
            ajustIntervF1=(tauxErr*ecartTypAtteF1)/sqrt(nbreSimul*T_max); %moyenAttente1);
                %%%%%%%%
            ecartTypAtteF2= std(cumulSim2);
            ajustIntervF2=(tauxErr*ecartTypAtteF2)/sqrt(nbreSimul*T_max); %moyenAttente2);

            fprintf(fiAVG, '%g \t %g \t %g  \t %g   \t %g  \t %g\n', moyenAttente1,ajustIntervF1, moyenAttente2,ajustIntervF2, moyenTrame, ajustIntervTram  );  %indice de la trame et sa taille
            fclose(fiAVG); %fichier contenant le nombre moyen de cllients dans chaque file
            succcccc2=movefile(fichierMoye, NEWDIR, 'f');
            succeeeeaaa=movefile(fichier, fileBuf, 'f');
            succ2bbb=movefile(fileBuf, NEWDIR, 'f');
      end
          succeeee=movefile(fichier, fichTMP, 'f');
      end
   
          succffffffff=movefile(fichhhh, NEWDiii, 'f');
          allRep=movefile(testttt, NEWDiii, 'f');
end