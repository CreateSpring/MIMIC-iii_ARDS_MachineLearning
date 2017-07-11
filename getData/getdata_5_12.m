%������ȡ���ݣ�ÿ�����˵����ݱ�����һ���ļ��У���ID����Ϊ�ļ������������������������Ϣ�����˻�����Ϣ��chartevents����
%2017.5.12
%�������˱���
%���ﲻ�Բ��˵Ĳ�������ɸѡ�ˣ���ȡ���в��˵ľ�����Ϣ���������Һ��ʵĲ�������
%��ȡ���˵����������� 
%���˻�����Ϣ��Ҫ���������� ����
clear all;
conn = database('PostgreSQL30','postgres','19871115');
%��Ҫ�ҵ�����Ҫ�Ĳ����ţ�������ICD=51881Ϊ�� 
Pat_ID='select adm.hadm_id from mimiciii.admissions adm';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
%save ('D:/ARDS/data1/Pat_ID.mat','data');
%��ʼ����ID����ѯ���в��ˣ�ÿ��������ID�ű�������
%Pat_Para_Value_SQLֻ�Ǳ���������Ҫ�Ĳ��˵Ĳ�����Ϣ���һ���Ҫ���˵Ļ�����Ϣ�������䡢�Ա����塢ICU��Ժ���ڵȵ�
%icd51881 �������䡢�Ա�
%pat_icu�в���icu��������Ϣ��subject_id��hadm_id�� first_careunit�� intime outtime
%deathtime age gender
%������ֻ��Ҫ��icd51881 ��pat_icu �������ϲ�ѯ�Ϳ��Եĵ����˵Ļ�����Ϣ
for i=1:length(data_ID)
    %��ȡ�����Ϣ
    Pat_dig_SQL=['select * from mimiciii.diagnoses_icd where hadm_id=' num2str(data_ID(i,1))];  
    %��ȡ������Ϣ
    Pat_w_SQL=['select round(avg(patientweight)) from mimiciii.inputevents_mv input where input.hadm_id=' num2str(data_ID(i,1))];
    %����ͼ�л�ȡ���˻�����Ϣ
    Pat_info_SQL=['select * from mimiciii.pat_icu where hadm_id=' num2str(data_ID(i,1))];    
    %��ȡ���˵�������Ϣ��race��chartevents��
    Pat_race_SQL=['select value from mimiciii.chartevents cha where cha.itemid=' num2str(226545) '  and cha.hadm_id=' num2str(data_ID(i,1)) ' limit 1' ];
    %������ȡ
    %������ȡ��720 ���������ò��� ��value����һ���ַ������� Ҫע��
    Pat_Para_Value_SQL =[ 'select distinct cha.subject_id,cha.hadm_id,cha.itemid,cha.value,cha.valuenum,cha.valueuom,para_id.para_flag,cha.charttime'...
        ' from mimiciii.chartevents cha'...
        ' inner join mimiciii.para_update para_id'...
        ' on cha.itemid=para_id.para_code'...
        ' inner join mimiciii.icustays icu'...
        ' on icu.hadm_id=cha.hadm_id'...
        ' where cha.hadm_id=' num2str(data_ID(i,1)) ' and cha.itemid in (select para_code from mimiciii.para_update )'...
        ' and cha.itemid=para_id.para_code '...
        ' and cha.charttime>icu.intime'...
        ' and cha.charttime<icu.outtime'...
        ' order by para_id.para_flag,cha.charttime ;'];
    %ִ��pat_dig_sql
    Pat_dig_value=exec(conn,Pat_dig_SQL);
    Pat_dig_value=fetch(Pat_dig_value);
    data_dig=Pat_dig_value.Data;
    %ִ��Pat_w_SQL
    Pat_w_value=exec(conn,Pat_w_SQL);
    Pat_w_value=fetch(Pat_w_value);
    data_w=Pat_w_value.Data;
    %ִ��pat_info_sql
    Pat_info_value=exec(conn,Pat_info_SQL);
    Pat_info_value=fetch(Pat_info_value);
    data_info=Pat_info_value.Data;
    data_info=data_info';
    %ִ��Pat_race_SQL
    Pat_race_value=exec(conn,Pat_race_SQL);
    Pat_race_value=fetch(Pat_race_value);
    data_race=Pat_race_value.Data;
    %ִ��pat_ipara_value_sql
    Pat_Values = exec(conn,Pat_Para_Value_SQL);
    Pat_Values = fetch(Pat_Values);
    data_Values=Pat_Values.Data;
    if length(data_Values)>1 && length(data_info)>1 && length(data_dig)>1
    filename=strcat('D:/mimicdata/allpatientsdata/',num2str(data_ID(i,1)),'.mat');
    save (filename,'data_info','data_dig','data_Values','data_w','data_race');
    end
    i
end
close(conn);
