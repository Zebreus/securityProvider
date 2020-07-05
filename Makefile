#Paths
OUTPUT = ./out/
MAIN = ./src/
SERVER = ./src/server/
CLIENT = ./src/client/
JWT = ./libs/jwt-cpp/
NLOHMANN_JSON = ./libs/json/
CXXOPTS = ./libs/cxxopts/
SPDLOG = ./libs/spdlog/
RESOURCES = ./res/

#Configuration
CPP  = g++
CPPFLAGS = -Wall -Wformat -Os -std=c++17

#Debug keys
PRIVATE_KEY = $(RESOURCES)/private_key.pem
PUBLIC_KEY = $(RESOURCES)/public_key.pem

#Sourcecode and flags
SERVER_EXE = server
SERVER_SOURCES = $(SERVER)/Server.cpp $(SERVER)/SecurityProvider.cpp
SERVER_OBJS = $(addsuffix .o, $(basename $(SERVER_SOURCES)))
SERVER_CPP = -I$(SPDLOG) -I$(JWT) -I$(CXXOPTS)
SERVER_LDFLAGS = -lpthread -L/usr/lib -lssl -lcrypto

CLIENT_EXE = client
CLIENT_SOURCES = $(CLIENT)/Client.cpp
CLIENT_OBJS = $(addsuffix .o, $(basename $(CLIENT_SOURCES)))
CLIENT_CPP = -I$(NLOHMANN_JSON)/ -I$(SPDLOG) -I$(JWT)  -I$(CXXOPTS)
CLIENT_LDFLAGS = -L/usr/lib -lssl -lcrypto

#Build rules
all: server client

$(SERVER_OBJS): %.o : %.cpp
	$(CPP) $(CPPFLAGS) $(SERVER_CPP) -c -o $@ $<
	
$(CLIENT_OBJS): %.o : %.cpp
	$(CPP) $(CPPFLAGS) $(CLIENT_CPP) -c -o $@ $<

$(SERVER_EXE): $(OUTPUT)/$(SERVER_EXE)

$(CLIENT_EXE): $(OUTPUT)/$(CLIENT_EXE)

$(OUTPUT)/$(SERVER_EXE): $(SERVER_OBJS)
	mkdir -p $(OUTPUT)
	$(CXX) -o $@ $^ $(SERVER_LDFLAGS)
	
$(OUTPUT)/$(CLIENT_EXE): $(CLIENT_OBJS)
	mkdir -p $(OUTPUT)
	$(CXX) -o $@ $^ $(CLIENT_LDFLAGS)
	
clean:
	rm -f $(SERVER_OBJS) $(CLIENT_OBJS)
	
distclean: clean
	rm -rf $(OUTPUT)
	
doku: 
	- doxygen Doxyfile

format: $(addprefix format-, $(wildcard $(MAIN)/*.*pp) $(wildcard $(MAIN)/*/*.*pp)))

format-$(MAIN)%.cpp: $(MAIN)%.cpp
	clang-format $< -style="{BasedOnStyle: webkit, IndentWidth: 4, TabWidth: 4, UseTab: ForContinuationAndIndentation}" > $<_2
	mv $<_2 $<
	rm -f $<_2

format-$(MAIN)%.hpp: $(MAIN)%.hpp
	clang-format $< -style="{BasedOnStyle: webkit, IndentWidth: 4, TabWidth: 4, UseTab: ForContinuationAndIndentation}" > $<_2
	mv $<_2 $<
	rm -f $<_2

format-$(MAIN)%.h: $(MAIN)%.h
	clang-format $< -style="{BasedOnStyle: webkit, IndentWidth: 4, TabWidth: 4, UseTab: ForContinuationAndIndentation}" > $<_2
	mv $<_2 $<
	rm -f $<_2
	
keys: $(PRIVATE_KEY) $(PUBLIC_KEY)

$(PRIVATE_KEY):
	mkdir -p $(RESOURCES)
	openssl genpkey -algorithm RSA -out $(PRIVATE_KEY) -pkeyopt rsa_keygen_bits:2048
	
$(PUBLIC_KEY): $(PRIVATE_KEY)
	openssl rsa -pubout -in $(PRIVATE_KEY) -out $(PUBLIC_KEY)

