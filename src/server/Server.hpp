#ifndef SERVER_HPP
#define SERVER_HPP

#include <sstream>
#include <string>
#include <filesystem>
#include <SecurityProvider.h>

//thrift
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TBufferTransports.h>
#include <thrift/TToString.h>
#include <thrift/concurrency/ThreadManager.h>
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/server/TThreadPoolServer.h>
#include <thrift/server/TThreadedServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TSocket.h>
#include <thrift/transport/TTransportUtils.h>

//spdlog
#include "spdlog/async.h"
#include "spdlog/async_logger.h"
#include "spdlog/sinks/daily_file_sink.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#include "spdlog/spdlog.h"

//json
#include <nlohmann/json.hpp>

//cxxopts
#include <cxxopts.hpp>

using namespace ::apache::thrift;
using namespace ::apache::thrift::protocol;
using namespace ::apache::thrift::transport;
using namespace ::apache::thrift::server;

using namespace  ::SecurityProviderThrift;

using namespace std;

bool dontCrash;

class SecurityProviderHandler : virtual public SecurityProviderIf {
 private:
  string peerAddress;
 public:
  SecurityProviderHandler(const string& peerAddress);
  
  ~SecurityProviderHandler();

  void authorize(const std::string& username, const std::string& password);
  
  void requestClaim(const std::string& claim);

  void getToken(std::string& _return);

};

class SecurityProviderCloneFactory : virtual public SecurityProviderIfFactory {
public:
	~SecurityProviderCloneFactory() override = default;

	SecurityProviderIf* getHandler(const ::apache::thrift::TConnectionInfo& connInfo) override;

	void releaseHandler(SecurityProviderIf* handler) override;
};

int main(int argc, char** argv);

#endif