Below is an instruction how to install the tool on a Linux.
Polem is provided as a source code package and must be compiled. The build system is based on CMake.
Built system provides executable that is installed to bin folder and shared library libpolem-dev.so that can be used in C/C++.

#### Requirements

Before running the build system, you need to ensure you have the following libraries installed with headers.

* Boost (tested with 1.58)
   ```bash
   sudo apt-get install libboost1.58-all-dev
   ```
* ICU library (tested with 55.1; Ubuntu package libicu-dev)
   ```bash
   sudo apt-get install libicu-dev
   ```
* CMake 3.2 or later
   ```bash
   sudo apt-get install cmake
   ```
* PwrUtils
   ```bash
   git clone https://gitlab.clarin-pl.eu/analysers/pwrutils.git
   cd pwrutils
   mkdir bin
   cd bin
   cmake ..
   make -j
   sudo make install
   sudo ldconfig
   cd ../..
   ```

* Corpus2
   ```bash
   git clone https://gitlab.clarin-pl.eu/analysers/corpus2.git
   cd corpus2
   mkdir bin
   cd bin
   cmake ../src
   make -j
   make -j
   sudo make install
   sudo ldconfig
   cd ../..
   ```

* WCCL
  ```bash
  sudo apt-get install -y libantlr-dev
  git clone https://gitlab.clarin-pl.eu/analysers/wccl.git
  cd wccl
  # tests and SWIG wrappers are not needed by Polem and may not compile with older Boost/ICU
  sed -i '/add_subdirectory(tests)/d' src/CMakeLists.txt src/libmwereader/CMakeLists.txt
  sed -i 's/set(WCCL_BUILD_SWIG True/set(WCCL_BUILD_SWIG False/' src/CMakeLists.txt
  mkdir bin
  cd bin
  cmake ../src
  make -j
  make -j
  sudo make install
  sudo ldconfig
  cd ../..
  ```   

* Morfeusz2 form generator
    ```bash
    wget -O morfeusz2.tar.gz https://download.sgjp.pl/morfeusz/20240107/Linux/18.04/64/morfeusz2-1.99.7.sgjp.20240107-Linux-amd64.tar.gz
    sudo tar -xzf morfeusz2.tar.gz --strip-components=1 -C /usr/local
    sudo ldconfig
    ```
    Packages for other systems are available at https://download.sgjp.pl/morfeusz/


#### Polem

Having installed the dependencies, install Polem:

```bash
mkdir polem/cpp/build
cd polem/cpp/build
cmake ..
make
sudo make install
```