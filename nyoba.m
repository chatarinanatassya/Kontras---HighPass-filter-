% Tentukan path ke direktori tempat gambar disimpan
path_to_images = 'D:\kuliah\semester 5\Pengelolahan Citra Digital\Chatarina Natassya P_UAS_PCD_07482_P';  % Ganti dengan path yang sesuai

% Ganti direktori kerja MATLAB ke path gambar
cd(path_to_images);

num_objects = 5;  % Jumlah objek gambar

% Inisialisasi variabel metrik evaluasi dan PSNR untuk setiap metode
TPR_asli_kontras = zeros(1, num_objects);
FNR_asli_kontras = zeros(1, num_objects);
FPR_asli_kontras = zeros(1, num_objects);
TNR_asli_kontras = zeros(1, num_objects);
MSE_asli_kontras = zeros(1, num_objects);
PSNR_asli_kontras = zeros(1, num_objects);

TPR_kontras_high_pass = zeros(1, num_objects);
FNR_kontras_high_pass = zeros(1, num_objects);
FPR_kontras_high_pass = zeros(1, num_objects);
TNR_kontras_high_pass = zeros(1, num_objects);
MSE_kontras_high_pass = zeros(1, num_objects);
PSNR_kontras_high_pass = zeros(1, num_objects);

TPR_asli_high_pass_direct = zeros(1, num_objects);
FNR_asli_high_pass_direct = zeros(1, num_objects);
FPR_asli_high_pass_direct = zeros(1, num_objects);
TNR_asli_high_pass_direct = zeros(1, num_objects);
MSE_asli_high_pass_direct = zeros(1, num_objects);
PSNR_asli_high_pass_direct = zeros(1, num_objects);

% Cell array untuk menyimpan gambar
result_images = cell(1, num_objects);

for obj = 1:num_objects
    % Baca citra asli
    file_asli = ['default' num2str(obj) '.jpg'];  % Format nama file sesuai dengan kebutuhan
    foto_asli = imread(file_asli);

    % Konversi ke grayscale jika foto_asli adalah RGB
    if size(foto_asli, 3) == 3
        foto_asli = rgb2gray(foto_asli);
    end

    % Metode Kontras
    kontras_factor = 1.5;
    [m, n] = size(foto_asli);
    foto_kontras = zeros(m, n);

    for i = 1:m
        for j = 1:n
            % Kalkulasi kontras 
            foto_kontras(i, j) = min(max(0, kontras_factor * double(foto_asli(i, j))), 255);
        end
    end

    foto_kontras = uint8(foto_kontras);

    % Hitung metrik evaluasi dan MSE untuk asli ke kontras
    TPR_asli_kontras(obj) = sum(foto_asli(:) >= 245 & foto_kontras(:) >= 245);
    FNR_asli_kontras(obj) = sum(foto_asli(:) >= 245 & foto_kontras(:) < 245);
    FPR_asli_kontras(obj) = sum(foto_asli(:) < 245 & foto_kontras(:) >= 245);
    TNR_asli_kontras(obj) = sum(foto_asli(:) < 245 & foto_kontras(:) < 245);
    MSE_asli_kontras(obj) = mean((double(foto_kontras(:)) - double(foto_asli(:))).^2);

    % Hitung PSNR untuk asli ke kontras
    if MSE_asli_kontras(obj) > 0
        max_intensity = double(max(foto_asli(:)));
        PSNR_asli_kontras(obj) = 10 * log10((max_intensity^2) / MSE_asli_kontras(obj));
    else
        PSNR_asli_kontras(obj) = inf;
    end

    % Metode High-pass
    kernel_high_pass = [0 -1 0; -1 5 -1; 0 -1 0];
    foto_high_pass = conv2(double(foto_kontras), kernel_high_pass, 'same');

    % Hitung metrik evaluasi dan MSE untuk kontras ke high-pass
    TPR_kontras_high_pass(obj) = sum(foto_kontras(:) >= 245 & foto_high_pass(:) >= 245);
    FNR_kontras_high_pass(obj) = sum(foto_kontras(:) >= 245 & foto_high_pass(:) < 245);
    FPR_kontras_high_pass(obj) = sum(foto_kontras(:) < 245 & foto_high_pass(:) >= 245);
    TNR_kontras_high_pass(obj) = sum(foto_kontras(:) < 245 & foto_high_pass(:) < 245);
    MSE_kontras_high_pass(obj) = mean((double(foto_high_pass(:)) - double(foto_kontras(:))).^2);

    % Hitung PSNR untuk kontras ke high-pass
    if MSE_kontras_high_pass(obj) > 0
        max_intensity = double(max(foto_kontras(:)));
        PSNR_kontras_high_pass(obj) = 10 * log10((max_intensity^2) / MSE_kontras_high_pass(obj));
    else
        PSNR_kontras_high_pass(obj) = inf;
    end

    % Segmentasi langsung dari asli ke high pass tanpa melalui kontras
    kernel_high_pass = [0 -1 0; -1 5 -1; 0 -1 0];
    foto_high_pass_direct = conv2(double(foto_asli), kernel_high_pass, 'same');

    % Hitung metrik evaluasi dan MSE untuk asli ke high pass tanpa melalui kontras
    TPR_asli_high_pass_direct(obj) = sum(foto_asli(:) >= 245 & foto_high_pass_direct(:) >= 245);
    FNR_asli_high_pass_direct(obj) = sum(foto_asli(:) >= 245 & foto_high_pass_direct(:) < 245);
    FPR_asli_high_pass_direct(obj) = sum(foto_asli(:) < 245 & foto_high_pass_direct(:) >= 245);
    TNR_asli_high_pass_direct(obj) = sum(foto_asli(:) < 245 & foto_high_pass_direct(:) < 245);
    MSE_asli_high_pass_direct(obj) = mean((double(foto_high_pass_direct(:)) - double(foto_asli(:))).^2);

    % Hitung PSNR untuk asli ke high pass tanpa melalui kontras
    if MSE_asli_high_pass_direct(obj) > 0
        max_intensity = double(max(foto_asli(:)));
        PSNR_asli_high_pass_direct(obj) = 10 * log10((max_intensity^2) / MSE_asli_high_pass_direct(obj));
    else
        PSNR_asli_high_pass_direct(obj) = inf;
    end

    % Menyimpan gambar dalam cell array
    result_images{obj} = {foto_asli, foto_kontras, uint8(foto_high_pass)};
end

% Tampilkan metrik akurasi, sensitivitas, spesifisitas, MSE, dan PSNR untuk setiap objek dan metode
fprintf('Metrik untuk Asli ke Kontras:\n');
for obj = 1:num_objects
    fprintf('Objek %d:\n', obj);
    fprintf('  Akurasi: %12.4f\n', ((TPR_asli_kontras(obj) + TNR_asli_kontras(obj)) / (TPR_asli_kontras(obj) + FNR_asli_kontras(obj) + FPR_asli_kontras(obj) + TNR_asli_kontras(obj))) * 100);
    fprintf('  Sensitivitas: %12.4f\n', (TPR_asli_kontras(obj) / (TPR_asli_kontras(obj) + FNR_asli_kontras(obj))) * 100);
    fprintf('  Spesifisitas: %12.4f\n', (TNR_asli_kontras(obj) / (TNR_asli_kontras(obj) + FPR_asli_kontras(obj))) * 100);
    fprintf('  MSE: %12.4f\n', MSE_asli_kontras(obj));
    fprintf('  PSNR: %12.4f\n', PSNR_asli_kontras(obj));
    fprintf('\n');
end

fprintf('Metrik untuk Kontras ke High-pass:\n');
for obj = 1:num_objects
    fprintf('Objek %d:\n', obj);
    fprintf('  Akurasi: %12.4f\n', ((TPR_kontras_high_pass(obj) + TNR_kontras_high_pass(obj)) / (TPR_kontras_high_pass(obj) + FNR_kontras_high_pass(obj) + FPR_kontras_high_pass(obj) + TNR_kontras_high_pass(obj))) * 100);
    fprintf('  Sensitivitas: %12.4f\n', (TPR_kontras_high_pass(obj) / (TPR_kontras_high_pass(obj) + FNR_kontras_high_pass(obj))) * 100);
    fprintf('  Spesifisitas: %12.4f\n', (TNR_kontras_high_pass(obj) / (TNR_kontras_high_pass(obj) + FPR_kontras_high_pass(obj))) * 100);
    fprintf('  MSE: %12.4f\n', MSE_kontras_high_pass(obj));
    fprintf('  PSNR: %12.4f\n', PSNR_kontras_high_pass(obj));
    fprintf('\n');
end

fprintf('Metrik untuk Citra Asli ke High Pass tanpa melalui kontras:\n');
for obj = 1:num_objects
    fprintf('Objek %d:\n', obj);
    fprintf('  Akurasi: %12.4f\n', ((TPR_asli_high_pass_direct(obj) + TNR_asli_high_pass_direct(obj)) / (TPR_asli_high_pass_direct(obj) + FNR_asli_high_pass_direct(obj) + FPR_asli_high_pass_direct(obj) + TNR_asli_high_pass_direct(obj))) * 100);
    fprintf('  Sensitivitas: %12.4f\n', (TPR_asli_high_pass_direct(obj) / (TPR_asli_high_pass_direct(obj) + FNR_asli_high_pass_direct(obj))) * 100);
    fprintf('  Spesifisitas: %12.4f\n', (TNR_asli_high_pass_direct(obj) / (TNR_asli_high_pass_direct(obj) + FPR_asli_high_pass_direct(obj))) * 100);
    fprintf('  MSE: %12.4f\n', MSE_asli_high_pass_direct(obj));
    fprintf('  PSNR: %12.4f\n', PSNR_asli_high_pass_direct(obj));
    fprintf('\n');
end

% Tampilkan citra asli, hasil kontras, dan hasil high-pass dalam satu figure
figure;
for obj = 1:num_objects
    subplot(3, num_objects, obj);
    imshow(result_images{obj}{1});  % Tampilkan citra asli
    title(['Citra Asli ' num2str(obj)]);

    subplot(3, num_objects, obj + num_objects);
    imshow(result_images{obj}{2});  % Tampilkan citra hasil kontras
    title(['Kontras ' num2str(obj)]);

    subplot(3, num_objects, obj + 2 * num_objects);
    imshow(result_images{obj}{3}, []);  % Tampilkan citra hasil high-pass
    title(['High-pass ' num2str(obj)]);
end
