module;

#include <cerrno>
#include <cstdio>

export module TestHelpers;

import std;

export namespace hlp
{
std::string remove_spaces(std::string text)
{
    auto filter = [](char ch) -> bool {
        return std::isspace(static_cast<unsigned char>(ch)) != 0;
    };

    const auto rng = std::ranges::remove_if(text, filter);
    return { text.begin(), rng.begin() };
}

void to_lower(std::string & text)
{
    auto make_lower = [](char ch) -> char {
        return static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
    };

    std::ranges::transform(text.begin(), text.end(), text.begin(), make_lower);
}

std::string normalize(std::string text)
{
    std::string result = remove_spaces(std::move(text));
    to_lower(result);
    return result;
}

// Runs command, returns console output
std::string exec(const std::string & cmd)
{
    std::array<char, 128> buffer;
    std::string output;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(
        popen(cmd.c_str(), "r"), pclose);

    if (!pipe) {
        throw std::runtime_error(std::format("Couldn't run {}", cmd));
    }

    while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe.get())
        != nullptr)
    {
        output += buffer.data();
    }

    return output;
}

std::string exec_user_solution()
{
    return exec("./build/main");
}

std::string read_text_file(std::string_view path)
{
    std::ifstream stream_in(path.data());
    std::ostringstream stream_out;
    stream_out << stream_in.rdbuf();
    return stream_out.str();
}

// Class stdout_capture_t - helper for capturing standard program output.
// Usage example:
//
//    std::string captured_text;
//    auto stdout_receiver = [&captured_text](std::string&& txt)
//    {
//        captured_text = std::move(txt);
//    };
//    std::println("PRINTLN 0");
//    {
//        hlp::stdout_capture_t capture(stdout_receiver);
//        std::println("PRINTLN 1");
//    }
//    std::println("PRINTLN 2");
//    std::print("OUT: {}", captured_text);
//
class stdout_capture_t final
{
public:
    using stdout_receiver_t = std::function<void(std::string&&)>;
    static constexpr std::string_view def_captured_out_path = "captured_stdout.txt";

    stdout_capture_t(std::string_view captured_out_path, stdout_receiver_t receiver);
    explicit stdout_capture_t(stdout_receiver_t receiver);
    ~stdout_capture_t();

    stdout_capture_t(const stdout_capture_t&) = delete;
    stdout_capture_t& operator=(const stdout_capture_t&) = delete;

private:
    std::string_view m_capture_path;
    stdout_receiver_t m_receiver;
};

stdout_capture_t::stdout_capture_t(std::string_view captured_out_path, stdout_receiver_t receiver)
    : m_capture_path(captured_out_path)
    , m_receiver(receiver)
{
    std::fflush(stdout);
    if (std::freopen(m_capture_path.data(), "w", stdout) == nullptr)
    {
        throw std::runtime_error(
            std::format("Can't open file `{}`. Error: `{}` ({}).", captured_out_path, std::strerror(errno), errno));
    }
}

stdout_capture_t::stdout_capture_t(stdout_receiver_t receiver)
    : stdout_capture_t(def_captured_out_path, receiver)
{
}

stdout_capture_t::~stdout_capture_t()
{
    try
    {
        std::fflush(stdout);
        if (std::freopen("/proc/self/fd/0", "w", stdout) == nullptr)
        {
            throw std::runtime_error(
                std::format("Can't open `/proc/self/fd/0`. Error: `{}` ({}).", std::strerror(errno), errno));
        }

        if (m_receiver)
        {
            m_receiver(read_text_file(m_capture_path));
        }
    }
    catch (const std::exception& err)
    {
        std::cerr
            << std::format("An unexpected error occurred while restoring the captured stdout. {}", err.what())
            << std::endl;
    }
}

} // namespace hlp
