%%
%File Name:tongji.m
%Author:������
%Version:v1.1
%Data:2017.05.15
%DESCRIPTION:
%           �Ի����������ɸѡ��mimiciii���ݿ��а����ܶ���������������Ҫ����ɸѡ��ǰ�������Ѿ������ߵ�������Ϣ��ȡ����
%           �洢��data_info�С���һ������������ǰ������塢��ߡ�������Ϣ����ȡ�����⣬�����������У����
%           end_data��û�б仯
%           data_info�������˵����л�����Ϣ������һ��
%           data_dig��û�б仯
%           �ļ��洢��mimicdata\matchdata_16
%           ����ȡ��7209�ݲ���
%%
%��ȡ����Ҫ�Ĳ���ID
clear all;
conn = database('PostgreSQL30','postgres','19871115');
Pat_ID='select icd.hadm_id from mimiciii.diagnoses_icd icd where icd.icd9_code in (select mimiciii.icdall.icd9_code from mimiciii.icdall) group by icd.hadm_id';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
close(conn);
% %����ƥ��õ����в�����Ӧ����ĸ���
% num=1;num_index=zeros(1,18);a=0;
% for file_num=1:length(data_ID)
%     filename=strcat('D:\mimicdata\matchdata\',num2str(data_ID(file_num,1)),'.mat');
%     if exist(filename, 'file')>0
%         data=matfile(filename);
%         match_data=data.end_data;
%         match_data(:,1)=[];
%         [length,~]=size(match_data);
%         [~,b]=find(match_data~=0);
%         class=unique(b);
%         [length,~]=size(class);
%         for i=1:length
%             num_index(1,class(i,1))=num_index(1,class(i,1))+sum(ismember(b,class(i,1)));
%         end
%     end
% end
%%
%����ɸѡ������ڵ���16��Ĳ��ˣ���������ȡ�������������Ϣ
for file_num=1:length(data_ID)
    filename=strcat('D:\mimicdata\matchdata\',num2str(data_ID(file_num,1)),'.mat');
    if exist(filename, 'file')>0
        data=matfile(filename);
        data_info=data.data_info;
        race=data.data_race;
        weight=data.data_w;
        end_data=data.end_data;
        data_dig=data.data_dig;
        if cell2mat(data_info(9,1))>=16
            %�������û����ӱ�ĵط���ȡ
            if strcmp(cellstr(race),'No Data')
                conn = database('PostgreSQL30','postgres','19871115');
                race_sql=strcat('select ethnicity from mimiciii.admissions adm where adm.hadm_id=',num2str(data_ID(file_num,1)));
                race=exec(conn,race_sql);
                race=fetch(race);
                race=race.Data;
                close(conn);
            end
            %��������
            if isnan(cell2mat(weight))
                conn = database('PostgreSQL30','postgres','19871115');
                weight_sql=strcat('select avg(patientweight) from mimiciii.inputevents_mv im where im.hadm_id=',num2str(data_ID(file_num,1)));
                weight=exec(conn,weight_sql);
                weight=fetch(weight);
                weight=weight.Data;
                close(conn);
            end
            %�������
            conn = database('PostgreSQL30','postgres','19871115');
            height_sql=strcat('select avg(valuenum) from mimiciii.chartevents cha where (cha.itemid=226730 or cha.itemid=226707) and cha.hadm_id=',num2str(data_ID(file_num,1)));
            height=exec(conn,height_sql);
            height=fetch(height);
            height=height.Data;
            close(conn);
            data_info(13,1)=race;data_info(14,1)=weight;data_info(15,1)=height;
            filename=strcat('D:\mimicdata\matchdata_16\',num2str(data_ID(file_num,1)),'.mat');
            save (filename,'end_data','data_info','data_dig');
        end
    end
end
