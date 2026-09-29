# Run this to install home brew and create necessary enviroment

# Install python versions

## Create new python envronment called ai
python3 -m venv ./python-env/ai
chmod +x ./python-env/ai/bin/activate

# install home brew
git clone --depth=1 https://github.com/Homebrew/brew ~/.brew

# clone containers repo
cd .. && git clone https://github.com/binuud/containers.git 
