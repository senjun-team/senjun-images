import std;

namespace hlp {
inline std::string remove_spaces(std::string text) {
    auto filter = [](char ch) -> bool {
        return std::isspace(static_cast<int>(ch)) != 0;
    };

    const auto rng = std::ranges::remove_if(text, filter);
    return { text.begin(), rng.begin() };
}

inline void to_lower(std::string & text) {
    auto make_lower = [](char ch) -> char {
        return static_cast<char>(std::tolower(static_cast<int>(ch)));
    };

    std::ranges::transform(text.begin(), text.end(), text.begin(), make_lower);
}

inline std::string normalize(std::string text) {
    std::string result = remove_spaces(std::move(text));
    to_lower(result);
    return result;
}

// Runs command, returns console output
inline std::string exec(const std::string & cmd) {
    std::array<char, 128> buffer;
    std::string output;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.c_str(), "r"), pclose);

    if (!pipe) {
        throw std::runtime_error(std::format("Couldn't run {}", cmd));
    }
    
    while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe.get()) != nullptr) {
        output += buffer.data();
    }
    
    return output;
}

inline std::string exec_user_solution() {
    return exec("./build/main");
}
} // namespace hlp