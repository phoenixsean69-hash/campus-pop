.pragma library
// CAMPUS_POP_FORMATTED_CODE_V38
// Safe rich-text renderer: html-escapes source material before formatting.
// Code highlighting is purely lexical, does not execute any source code.

function escapeHtml(value) {
    return String(value === undefined || value === null ? "" : value)
        .replace(/&/g, "&amp;").replace(/</g, "&lt;")
        .replace(/>/g, "&gt;").replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;")
}
function codeColors(dark) {
    return dark ? {
        base: "#E9EDF7", keyword: "#C6A5FF", string: "#8BE0C2",
        number: "#FFC78A", comment: "#96A7BA", prompt: "#79C9F7",
        bg: "#192536", edge: "#344960"
    } : {
        base: "#202A42", keyword: "#7B3FC0", string: "#08785D",
        number: "#BE5A1A", comment: "#61748C", prompt: "#156D9D",
        bg: "#F2F5FA", edge: "#D4DDE9"
    }
}
function colored(value, color) {
    return '<font color="' + color + '">' + escapeHtml(value) + '</font>'
}
function highlightCodeLine(text, dark) {
    var palette = codeColors(dark)
    var line = String(text)
    var out = ''
    var prompt = line.match(/^(\s*(?:>>>|\.\.\.)\s?)/)
    if (prompt) { out += colored(prompt[1], palette.prompt); line = line.slice(prompt[1].length) }

    // Tokens include comments, quote-delimited literals, numeric literals and words.
    // Only a small static keyword set is colored; arbitrary input remains escaped.
    var keyword = /^(?:and|as|assert|async|await|break|case|catch|class|const|continue|def|default|del|do|elif|else|enum|except|export|extends|false|False|finally|for|from|function|global|if|import|in|instanceof|interface|is|lambda|let|new|None|null|or|pass|print|private|protected|public|raise|return|static|struct|super|switch|this|throw|throws|true|True|try|var|void|while|with|yield)$/
    var regex = /#.*$|\/\/.*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*\b/g
    var last = 0, match
    while ((match = regex.exec(line)) !== null) {
        out += escapeHtml(line.slice(last, match.index))
        var token = match[0]
        var tone = ''
        if (token[0] === '#' || token.slice(0, 2) === '//') tone = palette.comment
        else if (token[0] === '"' || token[0] === "'" || token[0] === '`') tone = palette.string
        else if (/^\d/.test(token)) tone = palette.number
        else if (keyword.test(token)) tone = palette.keyword
        out += tone ? colored(token, tone) : escapeHtml(token)
        last = match.index + token.length
    }
    return out + escapeHtml(line.slice(last))
}
function codeBlock(lines, dark) {
    var p = codeColors(dark)
    var rendered = []
    for (var i = 0; i < lines.length; i++) rendered.push(highlightCodeLine(lines[i], dark))
    // Qt RichText supports pre, white-space:pre-wrap and CSS color/font-family.
    return '<pre style="font-family:Consolas,monospace;font-size:14px;' +
        'white-space:pre-wrap;background-color:' + p.bg + ';color:' + p.base +
        ';margin-top:8px;margin-bottom:14px;padding:12px;border-left:3px solid ' + p.edge + '">' +
        '<font face="Consolas">' + rendered.join('\n') + '</font></pre>'
}
function inlineText(raw, dark) {
    var s = escapeHtml(raw)
    // Markdown https links only; Qt must not load remote images from source markup.
    s = s.replace(/\[([^\]\n]{1,120})\]\((https:\/\/[^\s)<]{1,400})\)/g,
        '<a href="$2">$1</a>')
    var inlineColor = dark ? "#A9D7FF" : "#195E93"
    s = s.replace(/`([^`\n]{1,240})`/g,
        '<font face="Consolas" color="' + inlineColor + '">$1</font>')
    s = s.replace(/\*\*([^*\n]{1,300})\*\*/g, '<b>$1</b>')
    s = s.replace(/(^|[^*])\*([^*\n]{1,300})\*(?!\*)/g, '$1<i>$2</i>')
    return s
}
function isConsoleLine(s) { return /^\s*(?:>>>|\.\.\.)\s?/.test(s) }
function isOutputLine(s) {
    var t = s.trim()
    return /^(?:None|True|False|\[[^\]]*\]|\{[^}]*\}|\([^)]*\)|-?\d+(?:\.\d+)?|Traceback \(most recent call last\):|\S+Error:)/.test(t)
}
function isSourceLine(s) {
    return /^\s*(?:def\s+\w+\s*\(|class\s+\w+|import\s+\w+|from\s+\w+\s+import|return\s+|print\s*\(|for\s+\w+\s+in\s+|while\s+.+:|if\s+.+:|const\s+\w+\s*=|let\s+\w+\s*=|function\s+\w+\s*\(|#include\s*<|public\s+class\s+|System\.out\.print)/.test(s)
}
function render(raw, dark) {
    var input = String(raw === undefined || raw === null ? "" : raw)
    var lines = input.replace(/\r\n?/g, "\n").split("\n")
    var out = [], para = [], listType = "", code = [], codeOpen = false, firstNonEmpty = true
    dark = dark === true

    function flushParagraph() {
        if (para.length) {
            out.push('<p style="margin-top:0px;margin-bottom:10px">' + para.join('<br/>') + '</p>')
            para = []
        }
    }
    function flushList() {
        if (listType) {
            out.push(listType === 'ol' ? '</ol>' : '</ul>')
            listType = ""
        }
    }
    function flushCode() {
        if (code.length) { out.push(codeBlock(code, dark)); code = [] }
    }
    function label(line) {
        var m = line.match(/^(Source|Course|Learning objective|Guiding question|Hint|Try this|Answer|Key points(?: \(from your material\))?|Worked example(?: from your material)?|Check your understanding|Related|Example|Definition):\s*(.*)$/i)
        if (!m) return false
        flushParagraph(); flushList(); flushCode()
        out.push('<p style="margin-top:4px;margin-bottom:9px"><b>' + escapeHtml(m[1]) +
            ':</b>' + (m[2] ? '<br/>' + inlineText(m[2], dark) : '') + '</p>')
        return true
    }

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i], trimmed = line.trim()
        if (/^\s*```/.test(line)) {
            flushParagraph(); flushList()
            if (codeOpen) { flushCode(); codeOpen = false }
            else { flushCode(); codeOpen = true }
            continue
        }
        if (codeOpen) { code.push(line); continue }
        if (!trimmed) { flushParagraph(); flushList(); flushCode(); continue }

        if (firstNonEmpty && /^.{1,100}\s·\s.{1,80}$/.test(trimmed)) {
            out.push('<h3 style="margin-top:0px;margin-bottom:10px">' + inlineText(trimmed, dark) + '</h3>')
            firstNonEmpty = false
            continue
        }
        firstNonEmpty = false
        var heading = trimmed.match(/^#{1,4}\s+(.+)$/)
        if (heading) {
            flushParagraph(); flushList(); flushCode()
            out.push('<h3 style="margin-top:6px;margin-bottom:8px">' + inlineText(heading[1], dark) + '</h3>')
            continue
        }
        var bullet = line.match(/^\s*(?:[-*•])\s+(.+)$/)
        var numbered = line.match(/^\s*([0-9]{1,3})[.)]\s+(.+)$/)
        if (bullet || numbered) {
            flushParagraph(); flushCode()
            var kind = numbered ? 'ol' : 'ul'
            if (listType && listType !== kind) flushList()
            if (!listType) {
                out.push(kind === 'ol' ? '<ol style="margin-top:0px;margin-bottom:10px">' : '<ul style="margin-top:0px;margin-bottom:10px">')
                listType = kind
            }
            out.push('<li>' + inlineText(numbered ? numbered[2] : bullet[1], dark) + '</li>')
            continue
        }
        if (label(trimmed)) continue
        flushList()

        // Python documentation commonly uses interactive >>> / ... blocks rather
        // than Markdown fences. Do not render them as ordinary prose.
        if (isConsoleLine(line) || isSourceLine(line) || /^(?: {4,}|\t)\S/.test(line)) {
            flushParagraph()
            code.push(line)
            // Capture following prompts/indented code and simple interactive output.
            while (i + 1 < lines.length && lines[i + 1].trim() &&
                (isConsoleLine(lines[i + 1]) || isSourceLine(lines[i + 1]) ||
                 /^(?: {4,}|\t)\S/.test(lines[i + 1]) || isOutputLine(lines[i + 1]))) {
                code.push(lines[++i])
            }
            flushCode()
            continue
        }
        para.push(inlineText(trimmed, dark))
    }
    flushParagraph(); flushList(); flushCode()
    return '<html><body>' + (out.length ? out.join('') : '<p></p>') + '</body></html>'
}
