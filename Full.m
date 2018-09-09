clear
close all
clc

global citra citra_histeq

load data_hasil_training

[filename, pathname] = uigetfile('*.CR2','Pilih file citra','D:\DATA CLONE');
citra = imread([pathname filename]);
%figure; imshow(citra);

citra_histeq = preprosesing(citra);
ciri_uji = ekstraksi_ciri_glcm(citra_histeq);

[id_kelas,score,cost] = predict(Mdl,ciri_uji);
kelas_uji = target{id_kelas}

function citra_histeq = preprosesing(citra)

citra_gray = rgb2gray(citra);
citra_gray = imresize(citra_gray,[512,512]);
%figure; imshow(citra_gray);

level = graythresh(citra_gray); 
citra_bw = not(imbinarize(citra_gray, level)); %untuk membalik warna daunnya yang tadinya hitam jadi putih
citra_bw = bwareaopen(citra_bw, 1000);%utuk menghapus area yang dikurang dari 1000 pixel -> ini tergantung mau 1000 atau berapa
citra_bw = imfill(citra_bw,'holes');%untuk mengisi area yang kosong
%figure; imshow(citra_bw);

sum_baris = sum(citra_bw, 1);
bts_kiri = find(sum_baris > 0, 1, 'first');
bts_kanan = find(sum_baris > 0, 1, 'last');

sum_kolom = sum(citra_bw, 2);
bts_atas = find(sum_kolom > 0, 1, 'first');
bts_bawah = find(sum_kolom > 0, 1, 'last');

temp = double(citra_bw) .* double(citra_gray);
citra_daun_gray = temp(bts_atas:bts_bawah,bts_kiri:bts_kanan);
%figure; imshow(uint8(citra_daun_gray));

citra_histeq = histeq(uint8(citra_daun_gray));
%figure; imshow(uint8(citra_histeq));
end

function ciri_glcm = ekstraksi_ciri_glcm(citra_histeq)

jml_level = 8; %tergantung dicoba-coba sampai warna kontras dllnya pas
jarak = 2; % scan kearah tetangganya 
ofset = [0 1; -1 1;-1 0;-1 -1] .* jarak;% arah nya didapat dari matlab, jeraknya terserah

glcms = graycomatrix(citra_histeq,'NumLevels',jml_level,'Offset',ofset);%rumus glcm dari matlab
stats = graycoprops(glcms,{'contrast','correlation','energy','homogeneity'}); %variable yang dilihat dan akan diamati
ciri_glcm = [stats.Contrast stats.Correlation stats.Energy stats.Homogeneity];%menghasilkan 16 ciri karena setiap offset arah tersebut menghasilkan 4 nilai variable yang diamati
end 