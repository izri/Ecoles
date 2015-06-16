%by Nora IZRI; fichier pour pouvoir tracer les diff�rentes courbes de
%r�sultats 
%04/10/2013
clf

grid on
hold on

N=2; %nbre de files 
%tracer la fct de r�partion des proba cumul�s
tLeg=[];
    figure(1);
colorss=['b', 'm','r', 'g']; 
for pp=1:N
    nameFile= strcat('distribFile-', num2str(pp), '.dat'); %pr les attentes et transmis
    fiDistrib=load(nameFile); 

    plot(fiDistrib(:,1),fiDistrib(:,3),colorss(pp)); %, '*','LineWidth',2.0);  
    Spec = strcat('File' ,num2str(pp)); 
    tLeg=[tLeg; Spec]; 
    hold on
end
    legend(tLeg(1:N,:));
    xlabel('Buffer size');
    ylabel('Probability');

 
 filename1='taillesTrames.dat';
 filename2='indicesPerf.dat';
%  
%  %tracer les tailles des trames 
      fileT=load(filename1);
%     % y1=load(filename1,1,'A1:A10');
     

    %  plot(fileT(:,1),fileT(:,2),'-+','color','red','LineWidth',2.0);
    
 %   TailleTrame
      figure(2);
    %  plot(1:length(TailleTrame), TailleTrame);
      plot(fileT(:,1),fileT(:,3),'-+','color','red','LineWidth',2.0);
    
      xlabel('Trame ID');
      ylabel('Filling Frames (%)'); %Trame Size
%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     dataFile=load(filename2);
     [n,k]=size(dataFile);
if ((n>0) && (k>0))     
     [jj,ll]=sort(dataFile(:,1));
     dataFile=dataFile(ll,:);
     deb=0;
     figure(3);
     t=[];
     color=['r', 'g', 'b', 'm']; 
 
   for ii=1:N %nombre de file
        v=find(dataFile(:,1)==ii); % B= sortrows(A)  
   
        G{ii}=dataFile(deb+1:n, 2:k);
   
        %legend('Queue',1);   %1 en haut � droite
        %xlabel('TRame ID');
        %ylabel('Wait Queue');
       % figure(ii+1);
        plot(G{ii}(:,2),G{ii}(:,5), color(ii)); %,'*','color','blue','LineWidth',2.0);
        %plot(G{ii}(:,1),G{ii}(:,4),'r','LineWidth',1.5,'Marker','*');
        Spec_concat = strcat('Queue' ,num2str(ii)); 
        t=[t; Spec_concat]; 
        hold on
        if length(v)>0  deb=v(length(v));     
        end
   end
      legend(t(1:N,:));
      xlabel('Trame ID');
      ylabel('Wait Queue');
else
    fprintf('msg erreur ==> fichier vide \n');
    
end




figure(4);
%tracer la fct de r�partion des proba cumul�s
ttLeg=[];
colorss=['b', 'm','r', 'g']; 
for ppp=1:N
    nameFilee= strcat('indicePerffff-', num2str(ppp), '.dat'); %pr les attentes et transmis
    fiDistribb=load(nameFilee); 

    plot(fiDistribb(:,1),fiDistribb(:,4),colorss(ppp)); %, '*','LineWidth',2.0);  
    Spec = strcat('File' ,num2str(ppp)); 
    ttLeg=[ttLeg; Spec]; 
    hold on
end
    legend(ttLeg(1:N,:));
    xlabel('trame ID');
    ylabel('number');

 hold off
%     figure(2);
%     plot(dataFile(:,2),dataFile(:,5),'*','color','blue','LineWidth',2.0);