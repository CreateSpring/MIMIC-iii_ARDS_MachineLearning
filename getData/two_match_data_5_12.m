%%
%File Name:match_data_5_12.m
%Author:������
%Version:v1.1
%Data:2017.05.12
%DESCRIPTION:
%           ����ȡ�����ݽ���ƥ��
%           �������в��˵��ٴ����ݶ��洢��chartevents�У������ǵ�ʵ����Ҫ֪�������˼�¼PaO2ʱ��������ز��������Ծ�Ҫ��PaO2��¼ʱ��Ϊ׼Ѱ�Ҵ˲��˴�ʱ������������ݣ����ݻ�ȡʱ��
%           ���ǽ��������ݰ���hadm_id�����洢����ƥ��ǰ������Ҫ�����ݽ��е�һ��ɸѡ�����������Ϣ��ɸѡ������Ҫ�Ĳ��ˡ����ڲ��˵����������Ϣ������diagnoses_icd�У���������Ҫ��
%           ���id��icdall�У����ϲ�ѯ����ȡ������Ҫ�Ĳ��˵�hadm_id�����ջ�ȡ��8262�ݲ�������hadm_idΪ׼��
%           ƥ��õĽ������hadm_id�洢��mimicdata\matchdata\
%           ÿ���ļ�����end_data��data_info��data_race��data_w��data_dig
%           end_data��Ϊ����ƥ������ݣ�n*19�ľ��󣬵�һ��Ϊ����icuʱ�䣬��������Ϊ
%           data_info����������һ���Ĳ��˻�����Ϣ
%           data_race������
%           data_w����������
%           data_dig�������Ϣ
%%
%��ȡ��ؼ������ߵ�hadm_id
clear all;
conn = database('PostgreSQL30','postgres','19871115');
Pat_ID='select icd.hadm_id from mimiciii.diagnoses_icd icd where icd.icd9_code in (select mimiciii.icdall.icd9_code from mimiciii.icdall) group by icd.hadm_id';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
close(conn);
%%
%�����������Ԥ����
for file_num=1:length(data_ID)
    end_data=[];
    filename=strcat('D:\mimicdata\allpatientsdata\',num2str(data_ID(file_num,1)),'.mat');
    if exist(filename, 'file')>0
        data=matfile(filename);
        data_info=data.data_info;
        data_race=data.data_race;data_w=data.data_w;data_dig=data.data_dig;
        data_chart=data.data_Values;
        [data_chart_length,~]=size(data_chart);
        %��ʱ����д���
        data_chart(:,9)=num2cell(datenum(data_chart(:,8))-min(datenum(data_chart(:,8))));
        %�ȴ�����������,��itemid=223761�Ļ��϶�ת��Ϊ���϶�
        Temp_index=find(cell2mat(data_chart(:,3))==223761);
        [length_temp,~]=size(Temp_index);
        if length_temp>0
            for i=1:length_temp
                data_chart(Temp_index(i,1),5)=num2cell((cell2mat(data_chart(Temp_index(i,1),5))-32)/1.8);
            end
        end
        %��FiO2�ĵ�λ���е�����3420��223835������100
        for i=1:data_chart_length
            if cell2mat(data_chart(i,3))==3420 || cell2mat(data_chart(i,3))==223835
                data_chart(i,5)=num2cell(cell2mat(data_chart(i,5))/100);
            end
        end
        %�������˹����ָ��
        GSC_index=find(cell2mat(data_chart(:,7))>=19);
        [length_GSC,~]=size(GSC_index);
        if length_GSC>3
            GSC_temp=zeros(length_GSC,3);
            GSC_temp(:,1)=cell2mat(data_chart(GSC_index(1,1):end,9));
            GSC_temp(:,2)=cell2mat(data_chart(GSC_index(1,1):end,7));
            GSC_temp(:,3)=cell2mat(data_chart(GSC_index(1,1):end,5));
            data_GSC_group=zeros(length(unique(GSC_temp(:,1))),5);
            data_GSC_group(:,1)=unique(GSC_temp(:,1));
            for j=1:length_GSC
                time_index=find(data_GSC_group(:,1)==GSC_temp(j,1));
                data_GSC_group(time_index,GSC_temp(j,2)-17)=GSC_temp(j,3);
            end
            [zeros_x,~]=find(data_GSC_group(:,[2 3 4])==0);
            data_GSC_group(unique(zeros_x),:)=[];
            data_GSC_group(:,5)=data_GSC_group(:,2)+data_GSC_group(:,3)+data_GSC_group(:,4);
            data_chart(GSC_index(1,1):end,:)=[];
            [length_temp_GSC,~]=size(data_GSC_group);
            data_GSC_temp=zeros(length_temp_GSC,9);
            data_GSC_temp(:,9)=data_GSC_group(:,1);
            data_GSC_temp(:,5)=data_GSC_group(:,5);
            data_GSC_temp(:,7)=18;
            data_chart=[data_chart;num2cell(data_GSC_temp)];
        end
        %�Ժ�����ģʽ����ת��
        v_mode=find(cell2mat(data_chart(:,7))==1);
        [v_mode_length,~]=size(v_mode);
        mode={'Assist Control','SIMV+PS','SIMV', 'CMV', 'Pressure Control', 'Pressure Support' ,'Other/Remarks', 'CPAP', 'CPAP+PS', 'TCPCV'};
        for v_mode_index=1:v_mode_length
            [~,b]=ismember(data_chart(v_mode_index,4),mode);
            data_chart(v_mode_index,5)=num2cell(b);
        end
%%
        %�����ݽ��з���
        data_chart_temp=[cell2mat(data_chart(:,9)),cell2mat(data_chart(:,7)),cell2mat(data_chart(:,5))];
        data_chart_temp(:,2)=data_chart_temp(:,2)+1;
        [length_data_chart,~]=size(data_chart_temp);
        data_group=zeros(length(unique(data_chart_temp(:,1))),19);
        data_group(:,1)=unique(data_chart_temp(:,1));
        for k=1:length_data_chart
            if ~isnan(data_chart_temp(k,3))
                time_index=find(data_group(:,1)==data_chart_temp(k,1));
                data_group(time_index,data_chart_temp(k,2))=data_chart_temp(k,3);
            end
        end
%%
        %��ʼƥ��
        if sum(data_group(:,8))~=0%�ж��Ƿ���PaO2����
            %����ʱ�������и��£�ע��temp�к�data_group����һλ
            temp_1(1,1:18)=data_group(1,1);
            temp_1(2,1:18)=data_group(1,2:19);%��ʱ���������ȱ����һ����
            data_num=1;%ʵ��ƥ��ĵ���
            [data_group_y,~]=size(data_group);%��ȡdata_group�ĳ���
            for k=2:data_group_y
                %����ʱ�������и��£�ע��temp�к�data_group����һλ
                updata_index=find(data_group(k,2:19)>0);%���¿�ʼ�������ҵ���һ�в�Ϊ0��ֵ����������temp_1,����ʵ�ɴ洢���µ�ֵ
                for m=1:length(updata_index)
                    temp_1(1,updata_index(1,m))=data_group(k,1);
                    temp_1(2,updata_index(1,m))=data_group(k,updata_index(m)+1);
                end
                %����PaO2��Ҳ����data_group�ĵ�5���д���0��ֵ
                if data_group(k,8)>0 && k<data_group_y
                    para=k+1;%��pao2��һ�п�ʼ��
                    for n=1:11
                        while data_group(para,n+8)==0 && para<data_group_y
                            para=para+1;%û�ҵ��кžͼ�1
                        end
                        temp_2(1,n)=data_group(para,1);
                        temp_2(2,n)=data_group(para,n+8);
                        para=k+1;%���к����ÿ�ʼ����һ������
                    end
                    %temp_1��temp_2���Ƚ�
                    %���tepm_1����0 ˵��û�б��棬��ʱ���ֱ���滻temp_2�е�����
                    temp_3=temp_1;
                    for down_index=1:11
                        if temp_3(1,down_index+7)==0
                            temp_3(1,down_index+7)=temp_2(1,down_index);
                            temp_3(2,down_index+7)=temp_2(2,down_index);
                        else
                            if abs(temp_3(1,down_index+7)-temp_3(1,7))>abs(temp_2(1,down_index)-temp_3(1,7))
                                temp_3(1,down_index+7)=temp_2(1,down_index);
                                temp_3(2,down_index+7)=temp_2(2,down_index);
                            end
                        end
                    end
                    %temp_3�����˱ȽϺõ����ݣ����ڶ����ݵ�ʱ������ж�
                    for time_index=1:18
                        if time_index<=6
                            if abs(temp_3(1,time_index)-temp_3(1,7))>0.0417*24 && temp_3(2,time_index)~=0
                                temp_3(1,time_index)=0;
                                temp_3(2,time_index)=0;
                            end
                        else
                            if abs(temp_3(1,7)-temp_3(1,time_index))>0.0417
                                temp_3(1,time_index)=0;
                                temp_3(2,time_index)=0;
                            end
                        end
                    end
                    end_data(data_num,1)=temp_3(1,7);
                    end_data(data_num,2:19)=temp_3(2,:);
                    data_num=data_num+1;
                    temp_3=[];temp_2=[];
                end
            end
            if ~isempty(end_data)
                filename=strcat('D:\mimicdata\matchdata\',num2str(data_ID(file_num,1)),'.mat');
                save (filename,'end_data','data_info','data_race','data_w','data_dig');
                end_data=[];
            end
        end
    end
    %Ҫ���һЩ�ֲ���������������´������г���
    clear  data_chart data_group data_num down_index end_data filename i j k Lia m match_table n num para Para para_index temp_1 temp_2 temp_3 time_index updata_index data_chart_y  data_group_y data_chart_length data_chart_temp GSC_index length_data_chart length_GSC length_temp Temp_index;
end