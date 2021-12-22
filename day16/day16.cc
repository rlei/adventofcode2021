#include <algorithm>
#include <bitset>
#include <iostream>
#include <istream>
#include <iterator>
#include <memory>
#include <numeric>
#include <ranges>
#include <sstream>
#include <string_view>

enum TypeId
{
  Sum = 0,
  Product,
  Min,
  Max,
  Literal,
  GreaterThan,
  LessThan,
  EqualTo
};

class BitStringStream
{
private:
  std::istringstream is;
  int offset = 0;

public:
  BitStringStream(std::string str) : is(str) {}

  int getBits(int n)
  {
    char buf[n + 1];
    is.get(buf, n + 1);
    offset += n;
    return std::stoi(std::string(buf), 0, 2);
  }

  int getOffset()
  {
    return offset;
  }
};

struct Visitor
{
  virtual ~Visitor() = default;
  virtual void operatorPacket(int version, TypeId typeId) = 0;
  virtual void literalPacket(int version, int64_t literal) = 0;
};

struct Packet
{
  virtual ~Packet() = default;
  virtual int getVersion() const = 0;
  virtual TypeId getTypeId() const = 0;
  virtual void accept(Visitor& visitor) const = 0;
  virtual int64_t evaluate() const = 0;
};

class OperatorPacket : public Packet
{
private:
  int version;
  TypeId typeId;
  std::vector<std::shared_ptr<Packet>> subPackets;

public:
  OperatorPacket(int version, TypeId typeId, std::vector<std::shared_ptr<Packet>> subPackets)
      : version(version), typeId(typeId), subPackets(subPackets)
  {
    // std::cout << "Operator ver " << version << "; typeId " << typeId << "; sub packets " << subPackets.size() << std::endl;
  }

  int getVersion() const
  {
    return version;
  }

  TypeId getTypeId() const
  {
    return typeId;
  }

  void accept(Visitor& visitor) const
  {
    // std::cout << "visiting operator packet" << std::endl;
    visitor.operatorPacket(version, typeId);
    for (auto&& p: subPackets)
    {
      p->accept(visitor);
    }
  }

  int64_t evaluate() const
  {
    auto range = subPackets | std::views::transform([](auto &&p) -> int64_t
                                                    { return p->evaluate(); });
    std::ostringstream os;

    int64_t ret;
    switch (typeId)
    {
    case Sum:
      os << "+ ";
      std::copy(range.begin(), range.end(), std::ostream_iterator<int64_t>(os, ","));
      ret = std::accumulate(range.begin(), range.end(), 0ll);
      break;

    case Product:
      os << "* ";
      std::copy(range.begin(), range.end(), std::ostream_iterator<int64_t>(os, ","));
      ret = std::accumulate(range.begin(), range.end(), 1ll, [](int64_t a, int64_t b) -> int64_t
                             { return a * b; });
      break;

    case Min:
      os << "min ";
      std::copy(range.begin(), range.end(), std::ostream_iterator<int64_t>(os, ","));
      ret = *std::min_element(range.begin(), range.end());
      break;

    case Max:
      os << "max ";
      std::copy(range.begin(), range.end(), std::ostream_iterator<int64_t>(os, ","));
      ret = *std::max_element(range.begin(), range.end());
      break;

    case GreaterThan:
      os << range[0] << " > " << range[1];
      ret = range[0] > range[1];
      break;

    case LessThan:
      os << range[0] << " < " << range[1];
      ret = range[0] < range[1];
      break;

    case EqualTo:
      os << range[0] << " == " << range[1];
      ret = range[0] == range[1];
      break;

    default:
      throw "impossible execution flow";
    }
    os << " => " << ret;
    // std::cout << os.str() << std::endl;
    return ret;
  }
};

class LiteralPacket : public Packet
{
private:
  int version;
  int64_t literal;

public:
  LiteralPacket(int version, int64_t literal) : version(version), literal(literal)
  {
    // std::cout << "Literal ver " << version << "; val " << literal << std::endl;
  }

  int getVersion() const
  {
    return version;
  }

  TypeId getTypeId() const
  {
    return Literal;
  }

  void accept(Visitor& visitor) const
  {
    // std::cout << "visiting literal packet" << std::endl;
    visitor.literalPacket(version, literal);
  }

  int64_t evaluate() const
  {
    // std::cout << "literal " << literal << std::endl;
    return literal;
  }
};

std::string hexToBinString(std::string& input) {
  std::stringstream ss;

  auto out = input | std::views::transform(
              [](unsigned char c) -> std::string
              {
                int val = c >= 'A' ? std::toupper(c) - 'A' + 10 : c - '0';
                return std::bitset<4>(val).to_string();
              }) | std::views::join;

  for (auto c : out)
  {
    ss << c;
  }

  return ss.str();
}

int64_t parseLiteral(BitStringStream *bits) {
  int64_t val = 0;
  for (;;)
  {
    int64_t chunk = bits->getBits(5);

    val = (val << 4) | (chunk & 0xf);
    if ((chunk & 0x10) == 0)
    {
      break;
    }
  }
  return val;
}

std::shared_ptr<Packet> parse(BitStringStream *bits) {
  auto version = bits->getBits(3);
  auto typeId = TypeId(bits->getBits(3));

  if (typeId == Literal)
  {
    auto literal = parseLiteral(bits);
    auto packet = new LiteralPacket(version, literal);
    return std::shared_ptr<Packet>(packet);
  }

  auto subPackets = std::vector<std::shared_ptr<Packet>>();
  auto lengthType = bits->getBits(1);
  if (lengthType == 0)
  {
    auto bitsSubPackets = bits->getBits(15);
    auto startOffset = bits->getOffset();
    while (bits->getOffset() < startOffset + bitsSubPackets)
    {
      subPackets.push_back(parse(bits));
    }
  }
  else
  {
    auto numSubPackets = bits->getBits(11);
    while (numSubPackets-- > 0)
    {
      subPackets.push_back(parse(bits));
    }
  }
  auto packet = new OperatorPacket(version, typeId, subPackets);
  return std::shared_ptr<Packet>(packet);
}

class VersionAccumulator: public Visitor
{
private:
  int versionSum = 0;

public:
  void operatorPacket(int version, TypeId typeId)
  {
    versionSum += version;
  }

  void literalPacket(int version, int64_t literal)
  {
    versionSum += version;
  }

  int getVersionSum()
  {
    return versionSum;
  }
};

int main()
{
  std::string input;

  std::getline(std::cin, input);

  auto bitstream = BitStringStream(hexToBinString(input));

  auto packet = parse(&bitstream);
  auto versionAccum = VersionAccumulator();
  packet->accept(versionAccum);
  std::cout << "Version sum: " << versionAccum.getVersionSum() << std::endl;
  std::cout << "Evaluated to: " << packet->evaluate() << std::endl;

  return 0;
}