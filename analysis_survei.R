library(tidyverse)

data_path <- file.path(".", "data", "Survei Singkat Penggunaan 5G di Indonesia.csv")
survei <- read_csv(data_path)

names(survei)

survei <- survei %>%
  rename(aplikasi = `1. Aplikasi atau Use Case 5G apa yang paling anda tunggu?`, 
         teknologi = `2. Seberapa ingin anda menggunakan teknologi 5G?`, 
         usaha = `3. Jika anda pemilik usaha atau pengambil keputusan di perusahaan, seberapa ingin anda berinvestasi menggunakan teknologi 5G di perusahaan anda?`, 
         marketing = `4. Seberapa percaya anda perihal info, manfaat, keuntungan dan keterbatasan teknologi 5G yang didapat dari marketing/pemasaran?`, 
         teman = `5. Seberapa percaya anda perihal info, manfaat, keuntungan dan keterbatasan teknologi 5G yang didapat dari teman?`, 
         jumlah_teman = `6. Saat 5G sudah mulai digelar, berapa orang teman anda yang menggunakan 5G, sebelum anda ikut menggunakan juga?`, 
         media_massa = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Iklan di Media Massa (TV, Radio, Koran, dsb)]`, 
         media_sosial = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Ikan di Media Sosial (FB, Youtube, IG, Tiktok, dsb)]`, 
         tele = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Telemarketing (Via Telepon, Email, SMS, WA, dsb)]`, 
         endorse = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Endorsement selebriti atau figur publik ]`, 
         bonus_data = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Bonus GB data, SMS dan telpon]`, 
         cashback = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Cashback]`, 
         refferal = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Insentif ajak teman (refferal)]`, 
         voucher = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Voucher Belanja Merchant Lain]`, 
         undian = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Undian berhadiah]`, 
         komunitas = `7. Berikan skor masing-masing untuk jenis kegiatan pemasaran/marketing yang sesuai dengan pribadi anda (1 rendah, 5 tinggi) [Komunitas Bersama Pengguna Produk]`, 
         harga = `8. Berapa rata-rata harga gawai (device) 5G seperti Smartphone, Smart Watch, Smart Appliances, Drone, VR goggles, dsb. yang sesuai untuk anda?`, 
         anggaran = `9. Berapa rata-rata anggaran perbulan paket 5G yang sesuai untuk anda?`)

names(survei)
colSums(is.na(survei))

clean_survei <- survei[complete.cases(survei), ]

colSums(is.na(clean_survei))

count_aplikasi <- str_split(clean_survei$aplikasi, ";") %>% 
  unlist() %>% 
  table() %>% 
  as_tibble()

colnames(count_aplikasi) <- c("aplikasi", "n")

count_aplikasi %>%
  arrange(-n)

clean_survei %>%
  count(teknologi) %>%
  ggplot(aes(x = teknologi, 
             y = n)) +
  geom_col() +
  scale_x_continuous(breaks = 1:10)

clean_survei %>%
  count(usaha) %>%
  ggplot(aes(x = usaha, 
             y = n)) +
  geom_col() +
  scale_x_continuous(breaks = 1:10)

clean_survei %>%
  count(marketing) %>%
  ggplot(aes(x = marketing, 
             y = n)) +
  geom_col() +
  scale_x_continuous(breaks = 1:10)

clean_survei %>%
  count(teman) %>%
  ggplot(aes(x = teman, 
             y = n)) +
  geom_col() +
  scale_x_continuous(breaks = 1:10)

clean_survei %>%
  count(harga) %>%
  ggplot(aes(x = harga, 
             y = n)) +
  geom_col() 

clean_survei %>%
  count(anggaran) %>%
  ggplot(aes(x = anggaran, 
             y = n)) +
  geom_col() 

clean_survei %>%
  ggplot(aes(x = teknologi, y = marketing)) +
  geom_jitter(size = 3, alpha = 0.3)

clean_survei %>%
  ggplot(aes(x = teknologi, y = marketing)) +
  geom_point(size = 3, alpha = 0.3)

clean_survei %>%
  count(teknologi, marketing) %>%
  ggplot(aes(x = teknologi, y = marketing, size = n)) +
  geom_point()

cor(clean_survei$teknologi, clean_survei$marketing)

model <- lm(teknologi ~ marketing, data = clean_survei)

summary(model)

model <- lm(usaha ~ teman, data = survei)
summary(model)
