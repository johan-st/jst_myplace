import { Marked } from "marked";
import { markedHighlight } from "marked-highlight";
import hljs from 'highlight.js';
import hljs_gleam from '@gleam-lang/highlight.js-gleam'
import fs from 'fs/promises'
import path from 'path'
import frontmatter from 'frontmatter'

const marked = new Marked(
    markedHighlight({
        langPrefix: 'hljs language-',
        highlight(code, lang, info) {
            const language = hljs.getLanguage(lang) ? lang : 'plaintext';
            return hljs.highlight(code, { language }).value;
        }
    })
);
hljs.registerLanguage('gleam', hljs_gleam);

const sourceDir = path.normalize(import.meta.filename + "/../../src/posts")
const outputDir = path.normalize(import.meta.filename + "/../../priv/posts")


// Ensure the read access to source dir
fs.access(sourceDir, fs.constants.R_OK)
    .catch((err) => {
        console.error(err)
        process.exit(1)
    })

// Remove output dir if it exists
fs.stat(outputDir)
    .then(() => fs.rm(outputDir, { recursive: true, force: true }))
    .then(() => fs.mkdir(outputDir))
    .then(() => fs.access(outputDir, fs.constants.W_OK))
    .catch(err => {
        // console.log(5)
        if (err.errno !== -4058) {
            console.error(err)
        }
    })
    .then(() => fs.readdir(sourceDir))
    .then(files => {
        // console.log(10, files)
        for (const file of files) {
            // console.log(20, file)
            if (path.extname(file) === '.md') {
                // Read the markdown file
                fs.readFile(path.join(sourceDir, file), 'utf8')
                    .then(fileContent => {
                        // console.log(30)
                        // extract frontmatter and check it
                        const { data, content } = frontmatter(fileContent, { safeLoad: true })
                        assertData(data)


                        // an id to tie json to post
                        const randomId = Math.random().toString(36).slice(2);
                        data.uid = randomId

                        // console.log(40, data)
                        // console.log(41, content)
                        const html = marked.parse(content);

                        // console.log(45, html)
                        // Build the output file path
                        const outputPathDoc = path.join(outputDir, randomId + ".html");
                        const outputPathData = path.join(outputDir, randomId + '.json');

                        // console.log(50, outputPathData)
                        // Write the HTML to the output file
                        const writeData = fs.writeFile(outputPathData, JSON.stringify(data), { flag: "w+" })
                        const writeDoc = fs.writeFile(outputPathDoc, html, { flag: "w+" })
                        return Promise.all([writeData, writeDoc])
                    })
                    .catch(err => {
                        // console.log(60)

                        console.error(err)
                        process.exit(1)
                    })
            }
        }
    })
    .catch(err => {
        // console.log(70)
        console.error(err)
        process.exit(1)
    });




function assertData(data) {
    if (!data) { throw Error("data invalid, was:", data) }
    if (!data.slug) { throw Error("data invalid, expeted a slug") }
}