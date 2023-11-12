#!/usr/bin/env bash
set -eux


# Setup build environment
# NPROCS=1
# STDCXX=17
# PYVER=cp311

git clone https://github.com/wlav/cppyy --depth=1
git clone https://github.com/wlav/cppyy-backend --depth=1
git clone https://github.com/wlav/CPyCppyy --depth=1

# Patch dependencies to want 6.30.0 for cling (but don't update the version of clingwrapper)
sed -i "s/3\.0\.0/3.1.0/" cppyy/python/cppyy/_version.py
sed -i "s/6\.28\.0/6.30.0/" cppyy/installer/cppyy_monkey_patch.py cppyy/setup.py cppyy-backend/clingwrapper/setup.py cppyy-backend/clingwrapper/pyproject.toml CPyCppyy/setup.py CPyCppyy/pyproject.toml


# Prepare environment
/opt/python/${PYVER}-${PYVER}/bin/python3 -m venv /opt/build-venv
export PATH="/opt/build-venv/bin:$PATH"

# Build wheel for cppyy-cling
python3 -m pip install wheel build
pushd ./cppyy-backend/cling 
python3 create_src_directory.py
python3 -m build . -o /wheelhouse/
popd
    
# Install cppyy-cling, build cppyy-backend without isolation and don't check versions
python3 -m pip install /wheelhouse/cppyy_cling*.whl
pushd ./cppyy-backend/clingwrapper 
python3 -m build -n -x -w . -o /wheelhouse/
popd

# Install cppyy-backend, build CPyCppyy
python3 -m pip install /wheelhouse/cppyy_backend*.whl
pushd ./CPyCppyy
python3 -m build -n -x -w . -o /wheelhouse/
popd

# Install CPyCppyy, build cppyy, install cppyy (pure Python)
python3 -m pip install /wheelhouse/CPyCppyy*.whl
pushd ./cppyy 
python3 -m build -n -x -w . -o /wheelhouse/
popd


#auditwheel repair /tmp/wheels/cppyy_cling*.whl --plat "$PLAT" -w /wheelhouse
#auditwheel repair /tmp/wheels/cppyy_backend*.whl --plat "$PLAT" -w /wheelhouse
#auditwheel repair /tmp/wheels/CPyCppyy*.whl --plat "$PLAT" -w /wheelhouse
