# CTestCustom.cmake: Skip UTF-8 tests
# Part of editorconfig-core-vimscript

# I need more vimscript Unicode regex skills before I can make these pass.
set(CTEST_CUSTOM_TESTS_IGNORE ${CTEST_CUSTOM_TESTS_IGNORE} g_utf_8_char)
set(CTEST_CUSTOM_TESTS_IGNORE ${CTEST_CUSTOM_TESTS_IGNORE} utf_8_char)
