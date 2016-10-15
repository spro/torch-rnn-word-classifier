image = require 'image'

-- Turn a confusion matrix from nn.ConfusionMatrix into an image
-- TODO: Show rotated labels on x axis
function renderConfusion(conf)
    local w = conf.mat:size()[1]
    local p = 20

    local mat = conf.mat:clone():double()
    mat:mul(1 / mat:max())
    local im = image.scale(mat, w * p, 'simple')

    local im2 = torch.ones(3, w * p, w * p + 100):double()
    im2[{1, {}, {1, w * p}}] = im
    im2[{2, {}, {1, w * p}}] = im
    im2[{3, {}, {1, w * p}}] = im
    for oi = 1, #classes do
        im2 = image.drawText(im2, classes[oi], w * p + 5, p * (oi - 1) + 5)
    end
    return im2
end

