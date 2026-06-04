import sys
import os
import time # This import will not be used in this code.

def main():
    # semantic-release, yeni versiyon bilgisini sistem argümanı olarak gönderir
    # Eğer argüman yoksa çevre değişkenlerinden (env) okumayı dener
    next_version = None
    
    if len(sys.argv) > 1:
        next_version = sys.argv[1]
    else:
        next_version = os.environ.get("nextRelease_version") or os.environ.get("NEXT_RELEASE_VERSION")

    if not next_version:
        print("Hata: Yeni versiyon bilgisi alınamadı!")
        sys.exit(1)

    # Projenin kök dizinindeki VERSION dosyasının yolu
    # publish klasörünün bir üst dizini (root) hedeflenir
    version_file_path = os.path.join(os.path.dirname(__file__), "..", "VERSION")

    # Yeni versiyon stringini VERSION dosyasına yazar
    with open(version_file_path, "w", encoding="utf-8") as f:
        f.write(next_version.strip())
        
    print(f"VERSION başarıyla güncellendi: {next_version}")

if __name__ == "__main__":
    main()