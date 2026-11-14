-- Preview explainer text files with their colours, rendered by the same
-- code as the full-screen viewer (explain-view --render FILE WIDTH), so the
-- preview and the viewer always match:
--   *.md  -> glow with the gruvbox style     *.ans -> as-is, cut to width

local M = {}

function M:peek(job)
	local output, err = Command("explain-view")
		:arg("--render")
		:arg(tostring(job.file.url))
		:arg(tostring(job.area.w))
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()
	if not output then
		return ya.preview_widget(job, ui.Text(tostring(err)):area(job.area))
	end

	-- honour scrolling (job.skip lines) and only keep what fits
	local kept, n = {}, 0
	for line in output.stdout:gmatch("[^\n]*\n?") do
		if line == "" then break end
		n = n + 1
		if n > job.skip and n <= job.skip + job.area.h then
			kept[#kept + 1] = line
		end
	end
	if job.skip > 0 and n < job.skip + job.area.h then
		ya.emit("peek", { math.max(0, n - job.area.h), only_if = job.file.url, upper_bound = true })
		return
	end
	ya.preview_widget(job, ui.Text.parse(table.concat(kept)):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", { math.max(0, cx.active.preview.skip + job.units), only_if = job.file.url })
	end
end

return M
